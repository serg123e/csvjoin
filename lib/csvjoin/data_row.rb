# frozen_string_literal: true

require 'csv'

module CSVJoin
  # CSV::Row with specified important columns to compare
  class DataRow < CSV::Row
    include ImportantColumns
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
        # warn("something wrong, #{inspect}, f'#{field}'==nil") if self[field].nil?
        res << self[field]
      end
      return res.hash
    end

    #
    # Returns +true+ if this row contains the same headers and fields in the
    # same order as +other+.
    #
    def ==(other)
      @columns.each_with_index do |from, index|
        to = other.columns[index]
        # warn "something wrong" if self[from].nil? || other[to].nil?
        return false unless self[from].eql? other[to]
      end
      return true
    end
  end
end
