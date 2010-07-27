require File.dirname(__FILE__) + '/spec_helper'
require 'lib/deposited_paper'

describe "DepositedPaper" do
  describe "when creating a new object" do
    it "should set the reference property" do
      ref = "DEP1879-001"
      paper = DepositedPaper.new(ref)
    
      paper.reference.should == ref
    end

    it "should have a year" do
      ref = "DEP1879-001"
      paper = DepositedPaper.new(ref)
    
      paper.year.should == "1879"
    end
    
    it "should set the year to 'pre2007' given a reference of DEP07-001" do
      ref = "DEP07-001"
      paper = DepositedPaper.new(ref)
      
      paper.year.should == "pre2007"
    end
  end
  
  describe "when asked to save" do
    before do
      @paper = DepositedPaper.new("DEP1896-0001")
    end
    
    it "should not include blank values other than deposited_date and department" do
      RestClient.should_receive(:put).with("http://localhost:5984/deposits/DEP1896-0001", "    {\"deposited_date\":null,\"year\":\"1896\",\"department\":null}\n").and_return nil
      
      @paper.save
    end
    
    it "should set deposited_date and department values properly" do
      RestClient.should_receive(:put).with("http://localhost:5984/deposits/DEP1896-0001", "    {\"deposited_date\":\"31/02/1896\",\"year\":\"1896\",\"department\":\"test\"}\n").and_return nil
      
      @paper.deposited_date = "31/02/1896"
      @paper.department = "test"
      @paper.save
    end
    
    it "should treat the legislature field as an array" do
      RestClient.should_receive(:put).with("http://localhost:5984/deposits/DEP1896-0001", "    {\"deposited_date\":\"31/02/1896\",\"legislature\":[\"Lords\",\"Commons\"],\"year\":\"1896\",\"department\":\"test\"}\n").and_return nil
      
      @paper.deposited_date = "31/02/1896"
      @paper.department = "test"
      @paper.legislature = "Lords, Commons"
      @paper.save
    end
    
    it "should ignore duplicate records" do
      RestClient.should_receive(:put).and_raise(RestClient::Conflict)
      
      @paper.save
    end
  end
end
