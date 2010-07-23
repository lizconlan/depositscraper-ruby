require File.dirname(__FILE__) + '/spec_helper'
require 'lib/parser'

describe "Parser" do
  describe "when creating a new object" do
    it "should set the year, if given" do
      year = "2008"
      paper = Parser.new(year)
     
      paper.year.should == year
    end
    
    it "should not set the year, if none is given" do
      paper = Parser.new()
     
      paper.year.should == nil
    end
  end
end