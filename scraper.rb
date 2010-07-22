require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'lib/deposited_paper'

year = nil

if ARGV.first
  if ARGV.first[0..4] == "year="
    year = ARGV.first.split("=")[1]
  end
end

if year
  doc = Nokogiri::HTML(open("http://deposits.parliament.uk/deposited_papers.asp?year=#{year}"))
else
  doc = Nokogiri::HTML(open("http://deposits.parliament.uk/"))
end
table_rows = doc.xpath('//table[@class="DP"]/tr')

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
if paper
  paper.save
end