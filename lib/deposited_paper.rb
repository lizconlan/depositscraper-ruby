class DepositedPaper
  attr_accessor :reference, :legislative_body, :date, :department, :description, :legislation, :notes, :link_to_paper

  def initialize ref
    @reference = ref
  end
end