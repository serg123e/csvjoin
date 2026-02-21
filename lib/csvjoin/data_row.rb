# frozen_string_literal: true

require 'csv'

module CSVJoin
  # CSV::Row with specified important columns to compare
  class DataRow < CSV::Row
    include ImportantColumns

    attr_accessor :ignore_case

    def inspect
      "noside:#{super}"
    end

    def eql?(other)
      self == other
    end

    def hash
      res = []
      @weights.each_with_index do |_weight, index|
        field = @columns[index]
        val = self[field]
        val = val&.downcase if @ignore_case
        res << val
      end
      res.hash
    end

    #
    # Returns +true+ if this row contains the same headers and fields in the
    # same order as +other+.
    #
    def ==(other)
      @columns.each_with_index do |from, index|
        to = other.columns[index]
        left_val = self[from]
        right_val = other[to]
        if @ignore_case
          left_val = left_val&.downcase
          right_val = right_val&.downcase
        end
        return false unless left_val.eql? right_val
      end
      true
    end
  end
end
