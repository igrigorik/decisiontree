require 'rubygems'
require 'decisiontree'

# ---Discrete-----------------------------------------------------------------------------------------

# Read in the training data
training, attributes = [], nil
File.open('data/discrete-training.txt','r').each_line { |line| 
  data = line.strip.split(',')
  attributes ||= data
  training.push(data.collect {|v| (v == 'will buy') || (v == "won't buy") ? (v == 'will buy' ? 1 : 0) : v})
}

# Remove the attribute row from the training data
training.shift

# Instantiate the tree, and train it based on the data (set default to '1')
dec_tree = DecisionTree::ID3Tree.new(attributes, training, 1, :discrete)
dec_tree.train

#---- Test the tree....

# Read in the test cases
#    Note: omit the attribute line (first line), we know the labels from the training data
test = []
File.open('data/discrete-test.txt','r').each_line { |line| data = line.strip.split(',') 
  test.push(data.collect {|v| (v == 'will buy') || (v == "won't buy") ? (v == 'will buy' ? 1 : 0) : v})
}

# Let the tree predict the output and compare it to the true specified value
test.each { |t|   predict = dec_tree.predict(t); puts "Predict: #{predict} ... True: #{t.last}"; }

# Graph the tree, save to 'discrete.png'
dec_tree.graph("discrete")
