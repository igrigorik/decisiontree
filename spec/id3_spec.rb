require 'spec_helper'

describe describe DecisionTree::ID3Tree do

  describe "discrete attributes" do
    Given(:labels) { ["hungry", "color"] }
    Given(:data) do
      [
        ["yes", "red", "angry"],
        ["no", "blue", "not angry"],
        ["yes", "blue", "not angry"],
        ["no", "red", "not angry"]
      ]
    end
    Given(:tree) { DecisionTree::ID3Tree.new(labels, data, "not angry", :discrete) }
    When { tree.train }
    Then { tree.predict(["yes", "red"]).should == "angry" }
    Then { tree.predict(["no", "red"]).should == "not angry" }
  end

  describe "discrete attributes" do
    Given(:labels) { ["hunger", "happiness"] }
    Given(:data) do
      [
        [8, 7, "angry"],
        [6, 7, "angry"],
        [7, 9, "angry"],
        [7, 1, "not angry"],
        [2, 9, "not angry"],
        [3, 2, "not angry"],
        [2, 3, "not angry"],
        [1, 4, "not angry"]
      ]
    end
    Given(:tree) { DecisionTree::ID3Tree.new(labels, data, "not angry", :continuous) }
    When { tree.train }
    Then { tree.graph("continuous") }
    Then { tree.predict([7, 7]).should == "angry" }
    Then { tree.predict([2, 3]).should == "not angry" }
  end

  describe "a mixture" do
    Given(:labels) { ["hunger", "color"] }
    Given(:data) do
      [
        [8, "red", "angry"],
        [6, "red", "angry"],
        [7, "red", "angry"],
        [7, "blue", "not angry"],
        [2, "red", "not angry"],
        [3, "blue", "not angry"],
        [2, "blue", "not angry"],
        [1, "red", "not angry"]
      ]
    end
    Given(:tree) { DecisionTree::ID3Tree.new(labels, data, "not angry", color: :discrete, hunger: :continuous) }
    When { tree.train }
    Then { tree.graph("continuous") }
    Then { tree.predict([7, "red"]).should == "angry" }
    Then { tree.predict([2, "blue"]).should == "not angry" }
  end


end
