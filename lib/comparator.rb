# frozen_string_literal: true

require_relative 'data_parser'
require 'diff/lcs'
# require 'debug'

class Diff::LCS::NoReplaceDiffCallbacks
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

module CSVJoin
  class Comparator
    attr_accessor :columns, :weights
    attr_accessor :headers, :data, :rows

    def initialize
      @data = {}
      @rows = {}
    end

    def parse(t)
      if (File.exist? t)
        csv = CSV.read(t,headers: true)
      else
        csv = CSV.parse(t, headers: true)
      end

      #return csv

      csv
    end

    def csv_to_talimer_rows(csv, side:'undef')
      list = []
      csv.each do |row|
        row2 = DataRow.new(row.headers, row.fields)
        row2.comparator = self
        row2.side = side
        list << row2
      end

      list
    end

    def parse_side(source, side:'undef')
      @data[side] = parse(source)
      @rows[side] = csv_to_talimer_rows( @data[side], side:side )
    end

    def prepare(source1, source2)
      parse_side( source1, side:'left')
      parse_side( source2, side:'right')

      #@left_size = @data_left.headers.size
      #@right_size = @data_right.headers.size
      
      # same col names by default
      if (@columns.nil?)
        @columns = (@data['left'].headers & @data['right'].headers).map {|a| [a,a] }
        @weights = [ *[1] * (@columns.size) ]
      end
      
      @headers = [ *@data['left'].headers, "diff", *@data['right'].headers ]
      # @headers.flatten!
    end

    def lcs(source1,source2)
      prepare(source1,source2)
      lcs = Diff::LCS.lcs(@rows['left'],
                          @rows['right']) # , Diff::LCS::ContextDiffCallbacks).flatten(1)
      puts "===lcs==="
      puts lcs.join("\n")
      puts "========="
    end

    def compare(source1, source2)
      prepare(source1,source2)

      sdiff = Diff::LCS.sdiff(@rows['left'],
                              @rows['right'],
                              Diff::LCS::NoReplaceDiffCallbacks
      )

      # p sdiff.join(";\n")
      col_sep = ","
      row_sep = "\n"
      res = [@headers].join(col_sep) + row_sep
      left_empty_row =  [*[''] * @data['left'].headers.size]
      right_empty_row = [*[''] * @data['right'].headers.size]

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
          row = [left_row.fields, "===", right_row.fields]
        else
          warn "unknown action #{action}"
        end
        res += row.flatten.join(col_sep) + row_sep
      end
      res
    end

    def set_columns_to_compare(cols)
      @columns = []

      cols.scan(/([^,:=~]+)(?:[=\~])([^,:=~]+)/).each do |from, to|
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
      # warn("#{r1} #{r2}")
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
