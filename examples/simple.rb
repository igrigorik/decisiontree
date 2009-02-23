#!/usr/bin/ruby

require 'rubygems'
require 'decisiontree'
 
attributes = ['Temperature']
training = [
  [36.6, 'healthy'],
  [37, 'sick'],
  [38, 'sick'],
  [36.7, 'healthy'],
  [40, 'sick'],
  [50, 'really sick'],
]
 
# Instantiate the tree, and train it based on the data (set default to '1')
dec_tree = DecisionTree::ID3Tree.new(attributes, training, 'sick', :continuous)
dec_tree.train

test = [37, 'sick']
 
decision = dec_tree.predict(test)
puts "Predicted: #{decision} ... True decision: #{test.last}";
 
# Graph the tree, save to 'tree.png'
dec_tree.graph("tree")


