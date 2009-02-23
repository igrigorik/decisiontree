#The MIT License

###Copyright (c) 2007 Ilya Grigorik <ilya AT fortehost DOT com>

require File.dirname(__FILE__) + '/test_helper.rb'
require 'decisiontree'

class TestDecisionTree < Test::Unit::TestCase

  def setup
    @labels = %w(sun rain)
    @data = [
        [1, 0, 1],
        [0, 1, 0]
    ]
  end
  
  def test_truth
    dec_tree = DecisionTree::ID3Tree.new(@labels, @data, 1, :discrete)
    dec_tree.train
    
    assert 1, dec_tree.predict([1, 0])
    assert 0, dec_tree.predict([0, 1])
  end
end

