# frozen_string_literal: true

require_relative 'data_row'
require_relative 'callbacks'
require 'diff/lcs'


module CSVJoin
  LEFT = 1 # 'left'
  RIGHT = 2 # 'right'

  # Compare and join two tables
  class Comparator
    attr_accessor :columns, :weights
    attr_accessor :headers, :data, :rows
    attr_accessor :input_col_sep

    def initialize
      @data = []
      @rows = []
      @empty = []
      @input_col_sep = ","
    end

    def intuit_col_sep(line)
      return "," if line.nil?

      [",", ";", "\t"].max_by { |char| line.count(char) }
    end

    def intuit_separator(file)
      File.open(file, encoding: 'bom|utf-8').each do |line|
        @input_col_sep = intuit_col_sep(line)
        break
      end
      file
    end

    def parse(data)
      if File.exist? data
        intuit_separator(data)
        csv = CSV.read(data, headers: true, col_sep: @input_col_sep)
        raise "Wrong CSV" if csv == []
      else
        csv = CSV.parse(data, headers: true, col_sep: @input_col_sep)
      end
      csv
    end

    def csv_to_talimer_rows(csv, side: 'undef')
      list = []
      row_columns = columns.map { |c| side.eql?(LEFT) ? c.first : c.last }

      csv.each do |row|
        row2 = DataRow.new(row.headers, row.fields)
        row2.columns = row_columns
        row2.weights = weights
        row2.side = side

        list << row2
      end

      list
    end

    def parse_side(source, side: nil)
      @data[side] = parse(source)
      @empty[side] = [*[''] * @data[side].headers.size]
    end

    def prepare_rows(side: nil)
      @rows[side] = csv_to_talimer_rows(@data[side], side: side)
    end

    def prepare(source1, source2)
      parse_side(source1, side: LEFT)
      parse_side(source2, side: RIGHT)

      set_default_column_names

      prepare_rows(side: LEFT)
      prepare_rows(side: RIGHT)

      @headers = [*@data[LEFT].headers, "diff", *@data[RIGHT].headers]
    end

    # by default use columns with same names in both tables
    def set_default_column_names
      return unless @columns.nil?

      @columns = (@data[LEFT].headers & @data[RIGHT].headers).map { |a| [a, a] }
      @weights = [*[1] * @columns.size]
    end

    def action_verbose(action)
      repl = { "!": "!==", "-": "==>", "+": "<==", "=": "===" }
      raise "wrong action #{action}" unless repl.has_key? action.to_sym

      return repl[action.to_sym]
    end

    def compare(source1, source2)
      prepare(source1, source2)

      sdiff = Diff::LCS.sdiff(@rows[LEFT],
                              @rows[RIGHT],
                              Diff::LCS::NoReplaceDiffCallbacks)

      CSV.generate(row_sep: "\n", col_sep: @input_col_sep) do |csv|
        csv << @headers
        sdiff.each do |change|
          row = joined_row(change)
          csv << row
        end
      end
    end

    def joined_row(change)
      left_row = change.old_element.nil? ? @empty[LEFT] : change.old_element.fields
      right_row = change.new_element.nil? ? @empty[RIGHT] : change.new_element.fields
      [*left_row, action_verbose(change.action), *right_row]
    end

    def columns_to_compare(cols)
      @columns = []

      cols.scan(/([^,:=~]+)(?:[=~])([^,:=~]+)/).each do |from, to|
        @columns << [from, to]
      end

      @weights = [1, *[0] * (@columns.size - 1)]
    end
  end
end
