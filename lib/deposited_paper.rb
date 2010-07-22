class DepositedPaper
  attr_accessor :reference, :legislature, :deposited_date, :department, :description, :legislation, :notes, :link_to_paper

  def initialize ref
    @reference = ref
  end
end