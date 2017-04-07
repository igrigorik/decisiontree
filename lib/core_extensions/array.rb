class Array
  def entropy
    each_with_object(Hash.new(0)) do |i, result|
      result[i] += 1
    end.values.inject(0) do |sum, count|
      percentage = count.to_f / length
      sum + -percentage * Math.log2(percentage)
    end
  end
end

module ArrayClassification
  refine Array do
    def classification
      collect(&:last)
    end
  end
end

