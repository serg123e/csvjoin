# frozen_string_literal: true

require_relative 'data_parser'
require 'diff/lcs'
# require 'debug'

class Diff::LCS::TalimerDiffCallbacks
  # Returns the difference set collected during the diff process.
  attr_reader :diffs

  def initialize #:yields self:
    @diffs = []
    yield self if block_given?
  end

  def match(event)
    @diffs << Diff::LCS::ContextChange.simplify(event)
  end

  def discard_a(event)
    @diffs << Diff::LCS::ContextChange.simplify(event)
  end

  def discard_b(event)
    @diffs << Diff::LCS::ContextChange.simplify(event)
  end

  def change(event)
    discard_a(Diff::LCS::ContextChange.new("<", event.old_position, event.old_element, event.new_position, event.new_element))
    discard_b(Diff::LCS::ContextChange.new(">", event.old_position, event.old_element, event.new_position, event.new_element))

    # @diffs << Diff::LCS::ContextChange.simplify(event)
  end
end

module Tabalmer
  class Comparator
    attr_accessor :columns, :weights
    def initialize; end

    def self.compare(source1, source2)
      data1 = DataParser.parse(source1)
      data2 = DataParser.parse(source2)
      sdiff = Diff::LCS.sdiff(data1, data2, Diff::LCS::TalimerDiffCallbacks) # , Diff::LCS::ContextDiffCallbacks).flatten(1)

      # p sdiff.join(";\n")
      col_sep = ","
      row_sep = "\n"
      res = [data1.headers, "diff", data2.headers].join(col_sep) + row_sep
      left_empty_row =  [*[''] * data1.headers.size]
      right_empty_row = [*[''] * data2.headers.size]

      sdiff.each do |cc|
        action = cc.action
        left_row = cc.old_element
        right_row = cc.new_element

        case action
        when '!'
          row = [left_row.fields, "!==", right_row.fields]
        when '-'
          row = [left_row.fields, "==>", *right_empty_row]
        when '+'
          row = [*left_empty_row, "<==", right_row.fields]
        when '='
          row = [left_row.fields, "   ", right_row.fields]
        else
          warn "unknown action #{action}"
        end
        res += row.join(col_sep) + row_sep
      end
      res
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
