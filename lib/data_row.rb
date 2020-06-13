# frozen_string_literal: true

require 'csv'

module CSVJoin
  # CSV::Row with specified important columns to compare
  class DataRow < CSV::Row
    attr_accessor :columns, :weights
    attr_reader :side

    attr_writer :side

    def inspect
      "#{side}:#{super}"
    end

    def eql?(other)
      self == other
    end

    def hash
      if @columns
        res = []
        @weights.each_with_index do |_weight, index|
          field = @columns[index]
          warn("something wrong, #{inspect}, side #{side.inspect}, f'#{field}'==nil") if self[field].nil?
          res << self[field]
        end
        return res.hash
      else
        row.hash
      end
    end

    #
    # Returns +true+ if this row contains the same headers and fields in the
    # same order as +other+.
    #
    def ==(other)
      if @columns
        @columns.each_with_index do |from, index|
          to = other.columns[index]
          # warn "something wrong" if self[from].nil? || other[to].nil?
          return false unless self[from].eql? other[to]
        end
        return true
      else

        return @row == other.row if other.is_a? CSV::Row

        @row == other
      end
    end
  end
end
