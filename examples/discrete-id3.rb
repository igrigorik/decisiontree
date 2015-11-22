require 'rubygems'
require 'decisiontree'

# ---Discrete---

# Read in the training data
training = []
File.open('data/discrete-training.txt', 'r').each_line do |line|
  data = line.strip.split(',')
  attributes ||= data
  training_data = data.collect do |v|
    case v
    when 'will buy'
      1
    when "won't buy"
      0
    else
      v
    end
  end
  training.push(training_data)
end

# Remove the attribute row from the training data
training.shift

# Instantiate the tree, and train it based on the data (set default to '1')
dec_tree = DecisionTree::ID3Tree.new(attributes, training, 1, :discrete)
dec_tree.train

# ---Test the tree---

# Read in the test cases
# Note: omit the attribute line (first line), we know the labels from the training data
test = []
File.open('data/discrete-test.txt', 'r').each_line do |line|
  data = line.strip.split(',')
  test_data = data.collect do |v|
    case v
    when 'will buy'
      1
    when "won't buy"
      0
    else
      v
    end
  end
  training.push(test_data)
end

# Let the tree predict the output and compare it to the true specified value
test.each do |t|
  predict = dec_tree.predict(t)
  puts "Predict: #{predict} ... True: #{t.last}"
end

# Graph the tree, save to 'discrete.png'
dec_tree.graph('discrete')
