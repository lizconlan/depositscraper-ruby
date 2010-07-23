require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'lib/deposited_paper'

class Parser
  attr_accessor :year
  
  def initialize year=nil
    @year = year unless year.nil?
  end
  
  def parse
    if @year
      doc = Nokogiri::HTML(open("http://deposits.parliament.uk/deposited_papers.asp?year=#{@year}"))
    else
      doc = Nokogiri::HTML(open("http://deposits.parliament.uk/"))
    end
    
    table_rows = doc.xpath('//table[@class="DP"]/tr')

    if table_rows.empty?
      parse_basic_html()
    else
      parse_html(table_rows)
    end
  end
  
  private
    def parse_basic_html
      row_count = 99
      paper = nil
      table_rows = doc.xpath('//table/tr')
      table_rows.each do |row|
        if row.attribute('valign') and row.attribute('valign').value == "top"          
          paper.save if paper
          cells = row.xpath('td')
          unless cells[0].text == ""
            row_count = 1
            if @year == "pre2007"
              paper = DepositedPaper.new("DEP#{cells[0].text.gsub('/', '-')}")
            else
              paper = DepositedPaper.new(cells[0].text)
            end
            paper.legislature = cells[1].text
            paper.deposited_date = cells[2].text
            paper.department = cells[3].text
            paper.link_to_paper = cells[4].xpath('a').attribute('href').value
          end
        else
          row_count += 1
          case row_count
            when 2
              cells = row.xpath('td')
              paper.description = cells[1].text
            when 3
              cells = row.xpath('td')
              paper.legislation = cells[1].text
            when 4
              cells = row.xpath('td')
              paper.notes = cells[1].text
          end
        end
      end
      paper.save if paper
    end
  
    def parse_html table_rows
      paper = nil
      table_rows.each do |row|
        row.xpath('td').each do |cell|
          if cell.attribute('class')
            case cell.attribute('class').value
              when "ref"
                if paper
                  paper.save
                end
                paper = DepositedPaper.new(cell.text)
              when "leg"
                paper.legislature = cell.text
              when "date"
                paper.deposited_date = cell.text
              when "dept"
                paper.department = cell.text
              when "link"
                paper.link_to_paper = cell.xpath('a').attribute('href').value
              when "des"
                paper.description = cell.text
              when "legislation"
                paper.legislation = cell.text
              when "notes"
                paper.notes = cell.text
            end
          end
        end
      end
      paper.save if paper
    end
  
end