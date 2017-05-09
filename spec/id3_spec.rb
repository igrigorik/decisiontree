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

  describe "export ruleset from continuous data to ruby conditional blocks code" do
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
    When(:method_str_code) { tree.ruleset.to_method(:my_classify_method) }
    When{ eval(method_str_code) }
    Then { my_classify_method(7, 7).should == "angry" }
    Then { my_classify_method(2, 3).should == "not angry" }
  end

  describe "export ruleset from discrete data to a ruby method code" do
    Given(:labels) { ["hunger", "color"] }
    Given(:data) do
      [
        ["yes", "red", "angry"],
        ["no", "blue", "not angry"],
        ["yes", "blue", "not angry"],
        ["no", "red", "not angry"]
      ]
    end

    Given(:tree) { DecisionTree::ID3Tree.new labels, data, "not angry", :discrete }
    When { tree.train }
    When(:method_str_code) { tree.ruleset.to_method(:my_classify_method) }
    When{ eval(method_str_code) }
    Then { send(:my_classify_method, "yes", "red").should == "angry" }
    Then { my_classify_method("yes", "red").should == "angry" }
  end

  describe "export ruleset from discrete data with range values to a ruby method code" do
    Given(:labels) { ["Age","Education","Income","Marital Status"] }
    Given(:data) do
      [
        ["36 - 55","masters","high","single","will buy"],
        ["18 - 35","high school","low","single","will not buy"],
        ["36 - 55","masters","low","single","will buy"],
        ["18 - 35","bachelors","high","single","will not buy"],
        ["<= 18","high school","low","single","will buy"],
        ["18 - 35","bachelors","high","married","will not buy"],
        ["36 - 55","bachelors","low","married","will not buy"],
        [">= 55","bachelors","high","single","will buy"],
        ["36 - 55","masters","low","married","will not buy"],
        ["> 55","masters","low","married","will buy"],
        ["36 - 55","masters","high","single","will buy"],
        ["> 55","masters","high","single","will buy"]
      ]
    end

    Given(:tree) { DecisionTree::ID3Tree.new labels, data, "will not buy", :discrete }
    When { tree.train }
    When(:method_str_code) { tree.ruleset.to_method(:my_classify_method) }
    When { eval(method_str_code) }
    Then { send(:my_classify_method, "36 - 55","masters","high","single").should == "will buy" }
  end
end

describe DecisionTree::Ruleset do

  describe "#get_value_range" do 
    Given(:labels) { ["Age","Education","Income","Marital Status"] }
    Given(:data) do
      [
        ["36 - 55","masters","high","single","will buy"],
        ["18 - 35","high school","low","single","will not buy"],
        [">= 55","bachelors","high","single","will buy"]
      ]
    end

    Given(:ruleset) { DecisionTree::Ruleset.new(labels, data, "will not buy", :discrete) }

    Then { ruleset.get_value_range(">= 10").should == [nil, ">=", "10"] } 
    Then { ruleset.get_value_range("<= 10.1").should == [nil, "<=", "10.1"] }
    Then { ruleset.get_value_range("> 10.0").should == [nil, ">", "10.0"] }
    Then { ruleset.get_value_range("< 10").should == [nil, "<", "10"] }
    Then { ruleset.get_value_range("10 - 30").should == ["10", "-", "30"] }
    Then { ruleset.get_value_range(">=10").should == [nil, ">=", "10"] }
    Then { ruleset.get_value_range("<=10").should == [nil, "<=", "10"] }
    Then { ruleset.get_value_range(">10").should == [nil, ">", "10"] }
    Then { ruleset.get_value_range("<10").should == [nil, "<", "10"] }
    Then { ruleset.get_value_range("10-30.0").should == ["10", "-", "30.0"] }
  end

end
