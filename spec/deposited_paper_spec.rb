require File.dirname(__FILE__) + '/spec_helper'
require 'lib/deposited_paper'

describe "DepositedPaper" do
  describe "when creating a new object" do
    it "should set the reference property" do
      ref = "DEP1879-001"
      paper = DepositedPaper.new(ref)
    
      paper.reference.should == ref
    end
  end
end