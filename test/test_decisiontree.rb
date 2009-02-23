require 'test/helper.rb'

describe DecisionTree::ID3Tree do

  it "should work with a discrete dataset" do
    labels = %w(sun rain)
    data = [
      [1,0,1],
      [0,1,0]
    ]

    dec_tree = DecisionTree::ID3Tree.new(labels, data, 1, :discrete)
    dec_tree.train

    dec_tree.predict([1,0]).should == 1
    dec_tree.predict([0,1]).should == 0
  end

  it "should work with continuous dataset"

end

