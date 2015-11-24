require 'spec_helper'

describe describe DecisionTree::ID3Tree do

  describe "simple discrete case" do
    Given(:labels) { ["sun", "rain"]}
    Given(:data) do
      [
        [1,0,1],
        [0,1,0]
      ]
    end
    Given(:tree) { DecisionTree::ID3Tree.new(labels, data, 1, :discrete) }
    When { tree.train }
    Then { expect(tree.predict([1,0])).to eq 1 }
    Then { expect(tree.predict([0,1])).to eq 0 }
  end

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
    Then { expect(tree.predict(["yes", "red"])).to eq "angry" }
    Then { expect(tree.predict(["no", "red"])).to eq "not angry" }
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
    Then { expect(tree.predict([7, 7])).to eq "angry" }
    Then { expect(tree.predict([2, 3])).to eq "not angry" }
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
    Then { expect(tree.predict([7, "red"])).to eq "angry" }
    Then { expect(tree.predict([2, "blue"])).to eq "not angry" }
  end

  describe "infinite recursion case" do
    Given(:labels) { [:a, :b, :c] }
    Given(:data) do
      [
        ["a1", "b0", "c0", "RED"],
        ["a1", "b1", "c1", "RED"],
        ["a1", "b1", "c0", "BLUE"],
        ["a1", "b0", "c1", "BLUE"]
      ]
    end
    Given(:tree) { DecisionTree::ID3Tree.new(labels, data, "RED", :discrete) }
    When { tree.train }
    Then { expect(tree.predict(["a1","b0","c0"])).to eq "RED" }
  end

  describe "numerical labels case" do
    Given(:labels) { [1, 2] }
    Given(:data) do
      [
        [1, 1, true],
        [1, 2, false],
        [2, 1, false],
        [2, 2, true]
      ]
    end
    Given(:tree) { DecisionTree::ID3Tree.new labels, data, nil, :discrete }
    When { tree.train }
    Then {
      expect { tree.predict([1, 1]) }.to_not raise_error
    }
  end

  describe "create a figure" do
    after(:all) do
      File.delete("#{FIGURE_FILENAME}.png") if File.file?("#{FIGURE_FILENAME}.png")
    end

    Given(:labels) { ["sun", "rain"]}
    Given(:data) do
      [
        [1,0,1],
        [0,1,0]
      ]
    end
    Given(:tree) { DecisionTree::ID3Tree.new(labels, data, 1, :discrete) }
    When { tree.train }
    When(:result) { tree.graph(FIGURE_FILENAME) }
    Then { expect(result).to_not have_failed }
    And { File.file?("#{FIGURE_FILENAME}.png") }
  end
end
