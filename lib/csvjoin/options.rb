# frozen_string_literal: true

module CSVJoin
  # Table options
  class Options
    attr_reader :col_sep

    def hash
      { headers: true, row_sep: "\n", col_sep: @col_sep }
    end

    def initialize(col_sep: ',')
      @col_sep = col_sep
    end

    def intuit_col_sep(line)
      @col_sep = %W[, ; \t].max_by { |char| line.count(char) }
    end

    def intuit_separator(file)
      File.open(file, encoding: 'bom|utf-8').each do |line|
        @col_sep = intuit_col_sep(line)
        break
      end
      file
    end
  end
end
