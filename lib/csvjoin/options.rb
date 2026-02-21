# frozen_string_literal: true

module CSVJoin
  # Table options
  class Options
    attr_accessor :col_sep, :col_sep_right, :columns_to_compare, :ignore_case, :output_file, :output_sep

    def csv_options
      { headers: true, row_sep: "\n", col_sep: @col_sep }
    end

    # Keep #hash available for CSV generation with output separator
    def output_csv_options
      { headers: true, row_sep: "\n", col_sep: @output_sep || @col_sep }
    end

    def initialize(col_sep: ',', col_sep_right: nil, columns_to_compare: '', # rubocop:disable Metrics/ParameterLists
                   ignore_case: false, output_file: nil, output_sep: nil)
      self.col_sep = col_sep
      self.col_sep_right = col_sep_right
      self.columns_to_compare = columns_to_compare
      self.ignore_case = ignore_case
      self.output_file = output_file
      self.output_sep = output_sep
    end

    def suggest_sep(line)
      %W[, ; \t].max_by { |char| line.count(char) }
    end

    def suggest_sep_file(file)
      first_line = File.open(file, encoding: 'bom|utf-8', &:readline)
      self.col_sep = suggest_sep(first_line)
      file
    rescue EOFError
      file
    end

    def dup
      self.class.new(
        col_sep: @col_sep,
        col_sep_right: @col_sep_right,
        columns_to_compare: @columns_to_compare,
        ignore_case: @ignore_case,
        output_file: @output_file,
        output_sep: @output_sep
      )
    end
  end
end
