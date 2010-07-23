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

    unless @legislature == "" or @legislature.nil?
      paper_hash["legislature"] = @legislature.split(",").collect{ |x| x.strip }
    end
    paper_hash["deposited_date"] = @deposited_date
    paper_hash["department"] = @department
    paper_hash["description"] = @description unless @description == "" or @description.nil?
    paper_hash["legislation"] = @legislation unless @legislation == "" or @legislation.nil?
    paper_hash["notes"] = @notes unless @notes == "" or @notes.nil?
    paper_hash["link_to_paper"] = @link_to_paper unless @link_to_paper == "" or @link_to_paper.nil?

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
