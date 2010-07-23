require 'lib/parser'

year = nil

if ARGV.first
  if ARGV.first[0..4] == "year="
    year = ARGV.first.split("=")[1]
  end
end

parser = Parser.new(year)
parser.parse()