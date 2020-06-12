# frozen_string_literal: true

﻿require_relative 'lib/comparator.rb'

c = CSVJoin::Comparator.instance
t1 = ARGV.shift
t2 = ARGV.shift
params = ARGV.shift
c.columns_to_compare(params) if params

res = c.compare(t1, t2)

puts res
