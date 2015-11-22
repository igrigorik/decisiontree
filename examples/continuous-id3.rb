require 'rubygems'
require 'decisiontree'
include DecisionTree

# ---Continuous---

# Read in the training data
training = []
File.open('data/continuous-training.txt', 'r').each_line do |line|
  data = line.strip.chomp('.').split(',')
  attributes ||= data
  training_data = data.collect do |v|
    case v
    when 'healthy'
      1
    when 'colic'
      0
    else
      v.to_f
    end
  end
  training.push(training_data)
end

# Remove the attribute row from the training data
training.shift

# Instantiate the tree, and train it based on the data (set default to '1')
dec_tree = ID3Tree.new(attributes, training, 1, :continuous)
dec_tree.train

# ---Test the tree---

# Read in the test cases
# Note: omit the attribute line (first line), we know the labels from the training data
test = []
File.open('data/continuous-test.txt', 'r').each_line do |line|
  data = line.strip.chomp('.').split(',')
  test_data = data.collect do |v|
    if v == 'healthy' || v == 'colic'
      v == 'healthy' ? 1 : 0
    else
      v.to_f
    end
  end
  test.push(test_data)
end

# Let the tree predict the output and compare it to the true specified value
test.each do |t|
  predict = dec_tree.predict(t)
  puts "Predict: #{predict} ... True: #{t.last}"
end
