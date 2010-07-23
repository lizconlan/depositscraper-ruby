require File.dirname(__FILE__) + '/spec_helper'
require 'lib/parser'

describe "Parser" do
  describe "when creating a new object" do
    it "should set the year, if given" do
      year = "2008"
      parser = Parser.new(year)
     
      parser.year.should == year
    end
    
    it "should not set the year, if none is given" do
      parser = Parser.new()
     
      parser.year.should == nil
    end
  end
  
  describe "when preparing to parse html" do    
    describe "when not given a year" do
      it "should get the html from http://deposits.parliament.uk/" do
        parser = Parser.new()
        parser.should_receive(:open).with('http://deposits.parliament.uk/').and_return("")
        
        parser.parse()
      end
      
      describe "when given the year 2008" do
        it "should get the html from http://deposits.parliament.uk/deposited_papers.asp?year=2008" do
          parser = Parser.new("2008")
          parser.should_receive(:open).with('http://deposits.parliament.uk/deposited_papers.asp?year=2008').and_return("")

          parser.parse()
        end
      end
    end
  end
end