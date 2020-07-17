# frozen_string_literal: true

require_relative 'important_columns'
require_relative 'data_row'
require_relative 'app'
require_relative 'options'
require_relative '../diff_lcs_callbacks'
require_relative '../diff_lcs_change'
require_relative 'table'
require 'diff/lcs'

module CSVJoin
  # Compare and join two tables
  class Comparator
    attr_reader :left, :right, :options

    extend Forwardable
    def_delegators :@options, :columns_to_compare, :columns_to_compare=

    def initialize(options = Options.new(col_sep: ","))
      self.options = options
    end

    def prepare_table(source)
      Table.new(source, options)
    end

    def prepare(source_left, source_right)
      self.left = prepare_table(source_left)
      self.right = prepare_table(source_right)

      set_default_column_names

      left.prepare_rows
      right.prepare_rows
    end

    # by default use columns with same names in both tables
    def set_default_column_names
      if !columns_to_compare.empty?
        columns_to_compare.scan(/([^,:=~]+)([=~])([^,:=~]+)/).each do |from, operator, to|
          weight = operator.eql?('=') ? 1 : 0
          left.add_column from, weight
          right.add_column to, weight
        end
      else

        columns = (left.headers & right.headers)
        left.define_important_columns(columns)
        right.define_important_columns(columns)
      end
    end

    def generate_csv(diffs)
      CSV.generate(options.hash) do |csv|
        csv << [*left.headers, "diff", *right.headers]

        diffs.each do |change|
          csv << change.joined_row(left, right)
        end
      end
    end

    def compare(source_left, source_rigth)
      prepare(source_left, source_rigth)
      diffs = Diff::LCS.sdiff(left.rows,
                              right.rows,
                              Diff::LCS::NoReplaceDiffCallbacks)
      generate_csv(diffs)
    end

    private

    attr_writer :left, :right, :options
  end
end
