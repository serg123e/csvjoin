# frozen_string_literal: true

require 'csv'
module Tabalmer
  class DataRow < CSV::Row
    #
    # Returns +true+ if this row contains the same headers and fields in the
    # same order as +other+.
    #
    def ==(other)
      return @row == other.row if other.is_a? CSV::Row

      @row == other
    end
  end

  class DataParser
    def self.parse(t)
      csv = CSV.parse(t, headers: true)
      # return csv.rows

      list = []
      csv.each do |row|
        row = DataRow.new(row.headers, row.fields)
        # list << row
      end
      csv
    end
  end
end
