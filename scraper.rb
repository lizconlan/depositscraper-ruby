require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'lib/deposited_paper'


doc = Nokogiri::HTML(open("http://deposits.parliament.uk/"))
table_rows = doc.xpath('//table[@class="DP"]/tr')

papers = []
paper = nil

table_rows.each do |row|
  row.xpath('td').each do |cell|
    if cell.attribute('class')
      case cell.attribute('class').value
        when "ref"
          if paper
            papers << paper
            #output each paper to a data store here
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