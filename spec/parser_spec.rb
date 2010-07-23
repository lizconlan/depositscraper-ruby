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
  
  describe "when parsing html" do
    before do
       @paper = mock(DepositedPaper)
       @paper.stub!(:save)
    end
    
    describe "when given the year 2009" do
      it 'should parse the document correctly' do
        parser = Parser.new("2009")
        html = '<html><table class="DP"><tr valign="top">
          <td class="ref">DEP2010-1518</td>
          <td class="leg">Commons, Lords</td>
          <td class="date">21/07/2010</td>
          <td colspan="1" class="dept">Department for Transport</td>
          <td class="link"><A HREF="http://www.parliament.uk/deposits/depositedpapers/2010/DEP2010-1518.zip">DEP2010-1518.ZIP</A></td>
          </tr>
          <tr>
          <td colspan="3"></td>
          <td class="des" colspan="2">Description goes here</td>
          </tr>
          <tr>
          <td colspan="3"></td>
          <td class="legislation" colspan="2"><i></i></td>
          </tr>
          <tr>
          <td colspan="3"></td>
          <td class="notes" colspan="2"></td>
          </tr></table></html>'
        
        parser.should_receive(:open).with('http://deposits.parliament.uk/deposited_papers.asp?year=2009').and_return(html)
        
        DepositedPaper.should_receive(:new).with("DEP2010-1518").and_return(@paper)
        
        @paper.should_receive(:legislature=).with("Commons, Lords")
        @paper.should_receive(:deposited_date=).with("21/07/2010")
        @paper.should_receive(:department=).with("Department for Transport")
        @paper.should_receive(:link_to_paper=).with("http://www.parliament.uk/deposits/depositedpapers/2010/DEP2010-1518.zip")
        @paper.should_receive(:description=).with("Description goes here")
        @paper.should_receive(:legislation=).with("")
        @paper.should_receive(:notes=).with("")
        
        parser.parse()
      end
    end
    
    describe "when given the year 2008" do
      it 'should parse the document correctly' do
        parser = Parser.new("2008")
        html = '<html><table><tr><tr valign="top">
          <td>DEP2010-1518</td>
          <td>Commons, Lords</td>
          <td>21/07/2010</td>
          <td colspan="1" class="dept">Department for Transport</td>
          <td><A HREF="http://www.parliament.uk/deposits/depositedpapers/2010/DEP2010-1518.zip">DEP2010-1518.ZIP</A></td>
          </tr>
          <tr>
          <td colspan="3"></td>
          <td colspan="2">Description goes here</td>
          </tr>
          <tr>
          <td colspan="3"></td>
          <td colspan="2"><i></i></td>
          </tr>
          <tr>
          <td colspan="3"></td>
          <td colspan="2"></td>
          </tr></table></html>'
        
        parser.should_receive(:open).with('http://deposits.parliament.uk/deposited_papers.asp?year=2008').and_return(html)
        
        DepositedPaper.should_receive(:new).with("DEP2010-1518").and_return(@paper)
        
        @paper.should_receive(:legislature=).with("Commons, Lords")
        @paper.should_receive(:deposited_date=).with("21/07/2010")
        @paper.should_receive(:department=).with("Department for Transport")
        @paper.should_receive(:link_to_paper=).with("http://www.parliament.uk/deposits/depositedpapers/2010/DEP2010-1518.zip")
        @paper.should_receive(:description=).with("Description goes here")
        @paper.should_receive(:legislation=).with("")
        @paper.should_receive(:notes=).with("")
        
        parser.parse()
      end
    end
    
    describe "when given the year pre2007" do
      it 'should parse the document correctly' do
        parser = Parser.new("pre2007")
        html = '<html><table><tr valign="top"><td bgcolor="#e3e3e3"><b>07/2064</b></td><td bgcolor="#e3e3e3"><b></b></td><td bgcolor="#e3e3e3"><b>08/10/2007</b></td><td colspan="1" bgcolor="#e3e3e3" width="45%">Treasury</td><td bgcolor="#e3e3e3" width="25%" align="right"><A HREF=""></A></td></tr><tr><td colspan="3" /><td colspan="2">Tables showing lone parents of working age with dependent children as a proportion of the working population, taken from the 1981, 1991 and 2001 censuses.</td></tr><tr><td colspan="3" /><td><i></i></td></tr><tr><td colspan="3" /><td align="right"></td></tr>'
        
        parser.should_receive(:open).with('http://deposits.parliament.uk/deposited_papers.asp?year=pre2007').and_return(html)
        
        DepositedPaper.should_receive(:new).with("DEP07-2064").and_return(@paper)
        
        @paper.should_receive(:deposited_date=).with("08/10/2007")
        @paper.should_receive(:department=).with("Treasury")
        @paper.should_receive(:description=).with("Tables showing lone parents of working age with dependent children as a proportion of the working population, taken from the 1981, 1991 and 2001 censuses.")
        @paper.should_receive(:legislature=).with("")
        @paper.should_receive(:legislation=).with("")
        @paper.should_receive(:link_to_paper=).with("")
        @paper.should_receive(:notes=).with("")
        
        parser.parse()
      end
    end
    
  end
end