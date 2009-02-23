require 'rubygems'
require 'decisiontree'
include DecisionTree

# ---Continuous-----------------------------------------------------------------------------------------

# Read in the training data
training, attributes = [], nil
File.open('data/continuous-training.txt','r').each_line { |line| 
  data = line.strip.chomp('.').split(',') 
  attributes ||= data
  training.push(data.collect {|v| (v == 'healthy') || (v == 'colic') ? (v == 'healthy' ? 1 : 0) : v.to_f})
}

# Remove the attribute row from the training data
training.shift

# Instantiate the tree, and train it based on the data (set default to '1')
dec_tree = ID3Tree.new(attributes, training, 1, :continuous)
dec_tree.train

#---- Test the tree....

# Read in the test cases
#    Note: omit the attribute line (first line), we know the labels from the training data
test = []
File.open('data/continuous-test.txt','r').each_line { |line| 
  data = line.strip.chomp('.').split(',') 
  test.push(data.collect {|v| (v == 'healthy') || (v == 'colic') ? (v == 'healthy' ? 1 : 0) : v.to_f})
}

# Let the tree predict the output and compare it to the true specified value
test.each { |t| predict = dec_tree.predict(t);  puts "Predict: #{predict} ... True: #{t.last}"}
