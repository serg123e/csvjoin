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

    def prepare_table(source, col_sep_override: nil)
      opts = options
      if col_sep_override
        opts = options.dup
        opts.col_sep = col_sep_override
      end
      Table.new(source, opts)
    end

    def prepare(source_left, source_right)
      self.left = prepare_table(source_left)
      self.right = prepare_table(source_right, col_sep_override: options.col_sep_right)

      # Default output separator to left table's separator (unless user specified one)
      options.output_sep ||= left.options.col_sep

      set_default_column_names

      left.prepare_rows
      right.prepare_rows
    end

    # by default use columns with same names in both tables
    def set_default_column_names
      if columns_to_compare.empty?
        use_common_columns
      else
        parse_column_spec
      end
    end

    def generate_csv(diffs)
      CSV.generate(**options.output_csv_options) do |csv|
        csv << [*left.headers, "diff", *right.headers]

        diffs.each do |change|
          csv << change.joined_row(left, right)
        end
      end
    end

    def compare(source_left, source_right)
      prepare(source_left, source_right)
      diffs = Diff::LCS.sdiff(left.rows,
                              right.rows,
                              Diff::LCS::NoReplaceDiffCallbacks)
      generate_csv(diffs)
    end

    private

    attr_writer :left, :right, :options

    def use_common_columns
      columns = (left.headers & right.headers)
      raise "No common columns found between files" if columns.empty?

      left.define_important_columns(columns)
      right.define_important_columns(columns)
    end

    def parse_column_spec
      validate_columns_format(columns_to_compare)
      left_headers = left.headers
      right_headers = right.headers

      columns_to_compare.scan(/([^,:=~]+)([=~])([^,:=~]+)/).each do |from, operator, to|
        validate_column_exists(from, left_headers, "left")
        validate_column_exists(to, right_headers, "right")

        weight = operator.eql?('=') ? 1 : 0
        left.add_column from, weight
        right.add_column to, weight
      end
    end

    def validate_column_exists(column, headers, side)
      return if headers.include?(column)

      raise "Column '#{column}' not found in #{side} file. Available columns: #{headers.join(', ')}"
    end

    def validate_columns_format(spec)
      remainder = spec.gsub(/[^,:=~]+[=~][^,:=~]+/, '').gsub(/[,:]/, '').strip
      return if remainder.empty?

      raise "Invalid column specification: '#{spec}'. Expected format: col1=col2,col3~col4"
    end
  end
end
