# frozen_string_literal: true

require_relative 'data_parser'
module Tabalmer
  class Comparator
    attr_accessor :columns, :weights
    def initialize; end

    def self.compare(t1, t2)
      d1 = DataParser.parse(t1)
      d2 = DataParser.parse(t2)

      j = 0
      d1.each_with_index do |_row1, _i|
        if d2[j]

        end
      end
    end

    def set_columns_to_compare(cols)
      @columns ||= []

      cols.scan(/([^\,\:]+):([^\,\:]+)/).each do |from, to|
        @columns << [from, to]
      end
      @weights = [1, *[0] * (@columns.size - 1)]
    end

    def compare_field(r1, r2, from, to)
      if r1[from].eql? r2[to]
        return "==="
      else
        return "!=="
      end
    end

    def compare_rows(r1, r2)
      @weights.each_with_index do |weight, index|
        from, to = @columns[index]
        warn "#{index}: #{from}, #{to}, #{r1.inspect}, #{r1[from]}, #{r2[to]}"

        if weight >= 1
          return "!==" unless r1[from].eql? r2[to]
        else
          return "<=>" unless r1[from].eql? r2[to]
        end
      end
      return "==="

      return '<=>'
    end
  end
end
