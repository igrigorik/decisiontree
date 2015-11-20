# The MIT License
#
### Copyright (c) 2007 Ilya Grigorik <ilya AT igvita DOT com>
### Modifed at 2007 by José Ignacio Fernández <joseignacio.fernandez AT gmail DOT com>

class Object
  def save_to_file(filename)
    File.open(filename, 'w+') { |f| f << Marshal.dump(self) }
  end

  def self.load_from_file(filename)
    Marshal.load(File.read(filename))
  end
end

module DecisionTree
  Node = Struct.new(:attribute, :threshold, :gain)

  class ID3Tree
    def initialize(attributes, data, default, type)
      @used = {}
      @tree = {}
      @type = type
      @data = data
      @attributes = attributes
      @default = default
    end

    def train(data = @data, attributes = @attributes, default = @default)
      attributes = attributes.map(&:to_s)
      initialize(attributes, data, default, @type)

      # Remove samples with same attributes leaving most common classification
      data2 = data.inject({}) do |hash, d|
        hash[d.slice(0..-2)] ||= Hash.new(0)
        hash[d.slice(0..-2)][d.last] += 1
        hash
      end

      data2 = data2.map do |key, val|
        key + [val.sort_by { |_k, v| v }.last.first]
      end

      @tree = id3_train(data2, attributes, default)
    end

    def type(attribute)
      @type.is_a?(Hash) ? @type[attribute.to_sym] : @type
    end

    def fitness_for(attribute)
      case type(attribute)
      when :discrete
        proc { |a, b, c| id3_discrete(a, b, c) }
      when :continuous
        proc { |a, b, c| id3_continuous(a, b, c) }
      end
    end

    def id3_train(data, attributes, default, _used={})
      return default if data.empty?

      # return classification if all examples have the same classification
      return data.first.last if data.classification.uniq.size == 1

      # Choose best attribute:
      # 1. enumerate all attributes
      # 2. Pick best attribute
      # 3. If attributes all score the same, then pick a random one to avoid infinite recursion.
      performance = attributes.collect { |attribute| fitness_for(attribute).call(data, attributes, attribute) }
      max = performance.max { |a,b| a[0] <=> b[0] }
      min = performance.min { |a,b| a[0] <=> b[0] }
      max = performance.sample if max[0] == min[0]
      best = Node.new(attributes[performance.index(max)], max[1], max[0])
      best.threshold = nil if @type == :discrete
      @used.has_key?(best.attribute) ? @used[best.attribute] += [best.threshold] : @used[best.attribute] = [best.threshold]
      tree, l = {best => {}}, ['>=', '<']

      fitness = fitness_for(best.attribute)
      case type(best.attribute)
      when :continuous
        partitioned_data = data.partition do |d|
          d[attributes.index(best.attribute)] >= best.threshold
        end
        partitioned_data.each_with_index do |examples, i|
          tree[best][String.new(l[i])] = id3_train(examples, attributes, (data.classification.mode rescue 0), &fitness)
        end
      when :discrete
        values = data.collect { |d| d[attributes.index(best.attribute)] }.uniq.sort
        partitions = values.collect do |val|
          data.select do |d|
            d[attributes.index(best.attribute)] == val
          end
        end
        partitions.each_with_index do |examples, i|
          tree[best][values[i]] = id3_train(examples, attributes - [values[i]], (data.classification.mode rescue 0), &fitness)
        end
      end

      tree
    end

    # ID3 for binary classification of continuous variables (e.g. healthy / sick based on temperature thresholds)
    def id3_continuous(data, attributes, attribute)
      values = data.collect { |d| d[attributes.index(attribute)] }.uniq.sort
      thresholds = []
      return [-1, -1] if values.size == 1
      values.each_index do |i|
        thresholds.push((values[i] + (values[i + 1].nil? ? values[i] : values[i + 1])).to_f / 2)
      end
      thresholds.pop
      #thresholds -= used[attribute] if used.has_key? attribute

      gain = thresholds.collect do |threshold|
        sp = data.partition { |d| d[attributes.index(attribute)] >= threshold }
        pos = (sp[0].size).to_f / data.size
        neg = (sp[1].size).to_f / data.size

        [data.classification.entropy - pos * sp[0].classification.entropy - neg * sp[1].classification.entropy, threshold]
      end
      gain = gain.max { |a, b| a[0] <=> b[0] }

      return [-1, -1] if gain.size == 0
      gain
    end

    # ID3 for discrete label cases
    def id3_discrete(data, attributes, attribute)
      values = data.collect { |d| d[attributes.index(attribute)] }.uniq.sort
      partitions = values.collect { |val| data.select { |d| d[attributes.index(attribute)] == val } }
      remainder = partitions.collect { |p| (p.size.to_f / data.size) * p.classification.entropy }.inject(0) { |a, e| e += a }

      [data.classification.entropy - remainder, attributes.index(attribute)]
    end

    def predict(test)
      descend(@tree, test)
    end

    def graph(filename, file_type = 'png')
      require 'graphr'
      dgp = DotGraphPrinter.new(build_tree)
      dgp.write_to_file("#{filename}.#{file_type}", file_type)
    end

    def ruleset
      rs = Ruleset.new(@attributes, @data, @default, @type)
      rs.rules = build_rules
      rs
    end

    def build_rules(tree = @tree)
      attr = tree.to_a.first
      cases = attr[1].to_a
      rules = []
      cases.each do |c, child|
        if child.is_a?(Hash)
          build_rules(child).each do |r|
            r2 = r.clone
            r2.premises.unshift([attr.first, c])
            rules << r2
          end
        else
          rules << Rule.new(@attributes, [[attr.first, c]], child)
        end
      end
      rules
    end

    private

    def descend(tree, test)
      attr = tree.to_a.first
      return @default unless attr
      if type(attr.first.attribute) == :continuous
        return attr[1]['>='] if !attr[1]['>='].is_a?(Hash) && test[@attributes.index(attr.first.attribute)] >= attr.first.threshold
        return attr[1]['<'] if !attr[1]['<'].is_a?(Hash) && test[@attributes.index(attr.first.attribute)] < attr.first.threshold
        return descend(attr[1]['>='], test) if test[@attributes.index(attr.first.attribute)] >= attr.first.threshold
        return descend(attr[1]['<'], test) if test[@attributes.index(attr.first.attribute)] < attr.first.threshold
      else
        return attr[1][test[@attributes.index(attr[0].attribute)]] if !attr[1][test[@attributes.index(attr[0].attribute)]].is_a?(Hash)
        return descend(attr[1][test[@attributes.index(attr[0].attribute)]], test)
      end
    end

    def build_tree(tree = @tree)
      return [] unless tree.is_a?(Hash)
      return [['Always', @default]] if tree.empty?

      attr = tree.to_a.first

      links = attr[1].keys.collect do |key|
        parent_text = "#{attr[0].attribute}\n(#{attr[0].object_id})"
        if attr[1][key].is_a?(Hash)
          child = attr[1][key].to_a.first[0]
          child_text = "#{child.attribute}\n(#{child.object_id})"
        else
          child = attr[1][key]
          child_text = "#{child}\n(#{child.to_s.clone.object_id})"
        end
        label_text = "#{key} ''"
        if type(attr[0].attribute) == :continuous
          label_text.gsub!("''", attr[0].threshold)
        end

        [parent_text, child_text, label_text]
      end
      attr[1].keys.each { |key| links += build_tree(attr[1][key]) }

      links
    end
  end

  class Rule
    attr_accessor :premises
    attr_accessor :conclusion
    attr_accessor :attributes

    def initialize(attributes, premises = [], conclusion = nil)
      @attributes = attributes
      @premises = premises
      @conclusion = conclusion
    end

    def to_s
      str = ''
      @premises.each do |p|
        if p.first.threshold
          str += "#{p.first.attribute} #{p.last} #{p.first.threshold}"
        else
          str += "#{p.first.attribute} = #{p.last}"
        end
        str += "\n"
      end
      str += "=> #{@conclusion} (#{accuracy})"
    end

    def predict(test)
      verifies = true
      @premises.each do |p|
        if p.first.threshold # Continuous
          if !(p.last == '>=' && test[@attributes.index(p.first.attribute)] >= p.first.threshold) && !(p.last == '<' && test[@attributes.index(p.first.attribute)] < p.first.threshold)
            verifies = false
            break
          end
        else # Discrete
          if test[@attributes.index(p.first.attribute)] != p.last
            verifies = false
            break
          end
        end
      end
      return @conclusion if verifies
      nil
    end

    def get_accuracy(data)
      correct = 0
      total = 0
      data.each do |d|
        prediction = predict(d)
        correct += 1 if d.last == prediction
        total += 1 unless prediction.nil?
      end
      (correct.to_f + 1) / (total.to_f + 2)
    end

    def accuracy(data = nil)
      data.nil? ? @accuracy : @accuracy = get_accuracy(data)
    end
  end

  class Ruleset
    attr_accessor :rules

    def initialize(attributes, data, default, type)
      @attributes = attributes
      @default = default
      @type = type
      mixed_data = data.sort_by { rand }
      cut = (mixed_data.size.to_f * 0.67).to_i
      @train_data = mixed_data.slice(0..cut - 1)
      @prune_data = mixed_data.slice(cut..-1)
    end

    def train(train_data = @train_data, attributes = @attributes, default = @default)
      dec_tree = DecisionTree::ID3Tree.new(attributes, train_data, default, @type)
      dec_tree.train
      @rules = dec_tree.build_rules
      @rules.each { |r| r.accuracy(train_data) } # Calculate accuracy
      prune
    end

    def prune(data = @prune_data)
      @rules.each do |r|
        (1..r.premises.size).each do
          acc1 = r.accuracy(data)
          p = r.premises.pop
          if acc1 > r.get_accuracy(data)
            r.premises.push(p)
            break
          end
        end
      end
      @rules = @rules.sort_by { |r| -r.accuracy(data) }
    end

    def to_s
      str = ''
      @rules.each { |rule| str += "#{rule}\n\n" }
      str
    end

    def predict(test)
      @rules.each do |r|
        prediction = r.predict(test)
        return prediction, r.accuracy unless prediction.nil?
      end
      [@default, 0.0]
    end
  end

  class Bagging
    attr_accessor :classifiers
    def initialize(attributes, data, default, type)
      @classifiers = []
      @type = type
      @data = data
      @attributes = attributes
      @default = default
    end

    def train(data = @data, attributes = @attributes, default = @default)
      @classifiers = []
      10.times { @classifiers << Ruleset.new(attributes, data, default, @type) }
      @classifiers.each do |c|
        c.train(data, attributes, default)
      end
    end

    def predict(test)
      predictions = Hash.new(0)
      @classifiers.each do |c|
        p, accuracy = c.predict(test)
        predictions[p] += accuracy unless p.nil?
      end
      return @default, 0.0 if predictions.empty?
      winner = predictions.sort_by { |_k, v| -v }.first
      [winner[0], winner[1].to_f / @classifiers.size.to_f]
    end
  end
end
