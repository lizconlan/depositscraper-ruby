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
      parse_basic_html(doc)
    else
      parse_html(table_rows)
    end
  end
  
  private
    def parse_basic_html doc
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
            paper.department = parse_departments(cells[3].text)
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
                paper.save if paper
                paper = DepositedPaper.new(cell.text)
              when "leg"
                paper.legislature = cell.text
              when "date"
                paper.deposited_date = cell.text
              when "dept"
                paper.department = parse_departments(cell.text)
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
  
    def parse_departments(text)
      #always have Department in full
      text = text.gsub("Dept.", "Department").gsub("Dept", "Department")
      
      #split on Department of/for
      text = text.gsub(" Department of", "|Department of").gsub(" Department for", "|Department for")
      
      #split on Ministry of/for
      text = text.gsub(" Ministry of", "|Ministry of").gsub(" Ministry for", "|Ministry for")
      
      #split on Minister of/for
      text = text.gsub(" Minister of", "|Minister of").gsub(" Minister for", "|Minister for")
      
      #split on Office of/for
      text = text.gsub(" Office of", "|Office of").gsub(" Office for", "|Office for")
      #repair any instances of Central or Government Office that got broken by the last line
      text = text.gsub("Central|Office", "Central Office")
      text = text.gsub("Government|Office", "Government Office")
      
      #split after Agency
      text = text.gsub("Agency ", "Agency|")
      text = text.gsub("Agency|Wales", "Agency Wales")
      text = text.gsub("Agency|Northern Ireland", "Agency Northern Ireland")
      text = text.gsub("Agency|Scotland", "Agency Scotland")
      text = text.gsub("Agency|for", "Agency for")
      
      #split on Chief
      text = text.gsub(" Chief", "|Chief")
      text = text.gsub(" of|Chief", " of Chief")
      
      #split on HM
      text = text.gsub(" HM ", "|HM ")
      
      #split after Speaker
      text = text.gsub(/[s|S]peaker /i, "Office of the Speaker|")
      text = text.gsub("Office of the Office of the", "Office of the")
      
      #split after Prime Minister
      text = text.gsub("Prime Minister ", "Prime Minister|")
      
      #split after Treasury
      text = text.gsub("Treasury ", "Treasury|")
      text = text.gsub(" Treasury", "|Treasury")
      
      #split after Cabinet Office
      text = text.gsub("Cabinet Office ", "Cabinet Office|")
      #split on Cabinet Office
      text = text.gsub(" Cabinet Office", "|Cabinet Office")
      
      #split after Whips Office
      text = text.gsub("Whips Office ", "Whips Office|")
      
      #handle specific Offices
      text = text.gsub("Foreign and Commonwealth Office ", "Foreign and Commonwealth Office|")
      text = text.gsub(" Foreign and Commonwealth Office", "|Foreign and Commonwealth Office")
      text = text.gsub("Home Office ", "Home Office|")
      text = text.gsub(" Home Office", "|Home Office")
      text = text.gsub("Northern Ireland Office ", "Northern Ireland Office|")
      text = text.gsub(" Northern Ireland Office", "|Northern Ireland Office")
      text = text.gsub("Office for National Statistics ", "Office for National Statistics|")
      text = text.gsub("Office for Scotland ", "Office for Scotland|")
      
      #handle specific cases
      text = text.gsub(/CLERK OF THE PARLIAMENTS /i, "Clerk of the Parliaments|")
      text = text.gsub("Communities and Local Government ", "Communities and Local Government|")
      text = text.gsub("Council of Europe ", "Council of Europe|")
      text = text.gsub(" Crown Prosecution Service", "|Crown Prosecution Service")
      text = text.gsub("Crown Prosecution Service ", "Crown Prosecution Service|")
      text = text.gsub(" Law Commission", "|Law Commission")
      text = text.gsub("Ministry of Defence ", "Ministry of Defence|")
      text = text.gsub("Ministry of Justice ", "Ministry of Justice|")
      text = text.gsub(" National Assembly for Wales", "|National Assembly for Wales")
      text = text.gsub(" Speakers Committee on", "|Speakers Committee on")
      text = text.gsub("United Kingdom Statistics Authority ", "United Kingdom Statistics Authority|")
      text = text.gsub(" United Kingdom Statistics Authority", "|United Kingdom Statistics Authority")
      text = text.gsub("Welsh Assembly ", "Welsh Assembly|")
      text = text.gsub(" Welsh Assembly ", "|Welsh Assembly")
      
      text = text.gsub("Department for Business Enterprise and Regulatory Reform ", "Department for Business, Enterprise and Regulatory Reform|")
      text = text.gsub("Department for Business, Enterprise and Regulatory Reform ", "Department for Business, Enterprise and Regulatory Reform|")
      text = text.gsub("Department for Business, Innovation and Skills ", "Department for Business, Innovation and Skills|")
      text = text.gsub("Department for Children Schools and Families ", "Department for Children, Schools and Families|")
      text = text.gsub("Department for Children, Schools and Families ", "Department for Children, Schools and Families|")
      text = text.gsub("Department for Culture Media and Sport ", "Department for Culture, Media and Sport|")
      text = text.gsub("Department for Culture, Media and Sport ", "Department for Culture, Media and Sport|")
      text = text.gsub("Department for Education ", "Department for Education|")
      text = text.gsub("Department of Energy and Climate Change ", "Department of Energy and Climate Change|")
      text = text.gsub("Department for Environment, Food and Rural Affairs ", "Department for Environment, Food and Rural Affairs|")
      text = text.gsub("Department of Health ", "Department of Health|")
      text = text.gsub("Department for Innovation, Universities and Skills ", "Department for Innovation, Universities and Skills|")
      text = text.gsub("Department for International Development ", "Department for International Development|")
      text = text.gsub("Department for Transport ", "Department for Transport|")
      text = text.gsub("Department for Work and Pensions ", "Department for Work and Pensions|")
      
      #generic fixes
      text = text.gsub("|Office|", "|Office ")
      text = text.gsub(/\|Government(\||$)/, " Government")
      text = text.gsub("|and", " and")
      
      text = text.gsub("\n", "|") #more in hope than expectation
      
      #remove duplicate | chars and split into array
      text.squeeze("|").split("|")
    end
  
end