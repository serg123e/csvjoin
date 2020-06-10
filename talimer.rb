require_relative 'lib/comparator.rb'

c = Talimer::Comparator.instance
t1 = ARGV.shift
t2 = ARGV.shift
params = ARGV.shift

      c.set_columns_to_compare(params)
      res = c.compare(t1, t2)
puts res