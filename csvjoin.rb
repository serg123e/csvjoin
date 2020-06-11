require_relative 'lib/comparator.rb'

c = CSVJoin::Comparator.instance
t1 = ARGV.shift
t2 = ARGV.shift
params = ARGV.shift
if (params)
  c.set_columns_to_compare(params)
end

res = c.compare(t1, t2)

puts res