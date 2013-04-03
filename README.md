# Decision Tree

A ruby library which implements ID3 (information gain) algorithm for decision tree learning. Currently, continuous and discrete datasets can be learned.

- Discrete model assumes unique labels & can be graphed and converted into a png for visual analysis
- Continuous looks at all possible values for a variable and iteratively chooses the best threshold between all possible assignments. This results in a binary tree which is partitioned by the threshold at every step. (e.g. temperate > 20C)

## Features
- ID3 algorithms for continuous and discrete cases, with support for incosistent datasets.
- Graphviz component to visualize the learned tree (http://rockit.sourceforge.net/subprojects/graphr/)
- Support for multiple, and symbolic outputs and graphing of continuos trees.
- Returns default value when no branches are suitable for input

## Implementation

- Ruleset is a class that trains an ID3Tree with 2/3 of the training data, converts it into a set of rules and prunes the rules with the remaining 1/3 of the training data (in a C4.5 way).
- Bagging is a bagging-based trainer (quite obvious), which trains 10 Ruleset trainers and when predicting chooses the best output based on voting.

Blog post with explanation & examples: http://www.igvita.com/2007/04/16/decision-tree-learning-in-ruby/

## Example

```ruby
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

decision = dec_tree.predict([37, 'sick'])
puts "Predicted: #{decision} ... True decision: #{test.last}";

# => Predicted: sick ... True decision: sick

# Specify type ("discrete" or "continuous") in the training data
labels = ["hunger", "color"]
training = [
        [8, "red", "angry"],
        [6, "red", "angry"],
        [7, "red", "angry"],
        [7, "blue", "not angry"],
        [2, "red", "not angry"],
        [3, "blue", "not angry"],
        [2, "blue", "not angry"],
        [1, "red", "not angry"]
]

dec_tree = DecisionTree::ID3Tree.new(labels, data, "not angry", color: :discrete, hunger: :continuous)
dec_tree.train

decision = dec_tree.predict([7, "red"])
puts "Predicted: #{decision} ... True decision: #{test.last}";
```

## License

The MIT License - Copyright (c) 2006 Ilya Grigorik
