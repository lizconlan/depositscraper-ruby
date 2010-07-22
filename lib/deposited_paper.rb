require 'rubygems'
require 'json'
require 'rest_client'

DBSERVER = "http://localhost:5984"
DATABASE = "#{DBSERVER}/deposits"

class DepositedPaper
  attr_accessor :reference, :legislature, :deposited_date, :department, :description, :legislation, :notes, :link_to_paper

  def initialize ref
    @reference = ref
  end
  
  def save
    paper_hash = {}
    
    uuid = @reference

    paper_hash["legislature"] = @legislature.split(",").collect{ |x| x.strip }
    paper_hash["deposited_date"] = @deposited_date
    paper_hash["department"] = @department
    paper_hash["description"] = @description unless @description == ""
    paper_hash["legislation"] = @legislation unless @legislation == ""
    paper_hash["notes"] = @notes unless @notes == ""
    paper_hash["link_to_paper"] = @link_to_paper unless @link_to_paper == ""

    #convert the hash into a valid JSON doc
    doc = <<-JSON
    #{JSON.generate(paper_hash)}
    JSON

    begin
      #PUT the new record to the database
      RestClient.put("#{DATABASE}/#{uuid}", doc)
    rescue RestClient::Conflict
      #duplicate record, ignore
    end
    
  end
end