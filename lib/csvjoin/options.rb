# frozen_string_literal: true

module CSVJoin
  # Table options
  class Options
    attr_reader :col_sep
    attr_accessor :columns_to_compare

    def hash
      { headers: true, row_sep: "\n", col_sep: @col_sep }
    end

    def initialize(col_sep: ',', columns_to_compare: '')
      self.col_sep = col_sep
      self.columns_to_compare = columns_to_compare
    end

    def suggest_sep(line)
      %W[, ; \t].max_by { |char| line.count(char) }
    end

    def suggest_sep_file(file)
      File.open(file, encoding: 'bom|utf-8').each do |line|
        self.col_sep = suggest_sep(line)
        break
      end
      file
    end

    private

    attr_writer :col_sep
  end
end
