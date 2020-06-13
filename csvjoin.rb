# frozen_string_literal: true

require_relative 'lib/comparator.rb'

c = CSVJoin::Comparator.new
t1 = ARGV.shift
t2 = ARGV.shift
params = ARGV.shift
c.columns_to_compare(params) if params
c.input_col_sep = ";"
res = c.compare(t1, t2)

puts res
