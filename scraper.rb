require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'lib/deposited_paper'

year = nil
paper = nil

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

if table_rows.empty?
  row_count = 99
  table_rows = doc.xpath('//table/tr')
  table_rows.each do |row|
    if row.attribute('valign') and row.attribute('valign').value == "top"
      if paper
        paper.save
      end      
      cells = row.xpath('td')
      unless cells[0].text == ""
        row_count = 1
        paper = DepositedPaper.new(cells[0].text)
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
else
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
end
if paper
  paper.save
end