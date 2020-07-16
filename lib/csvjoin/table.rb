# frozen_string_literal: true

module CSVJoin
  # represents one table in comparison
  class Table
    include ImportantColumns
    attr_reader :rows, :options, :data

    def initialize(source, opts)
      self.options = opts
      self.data = parse(source)
      self.columns = []
      self.weights = []
    end

    def headers
      data.headers
    end

    def empty_row
      Array.new(headers.size) { '' }
    end

    def prepare_rows
      @rows = []

      data.each do |csv_row|
        data_row = DataRow.new(csv_row.headers, csv_row.fields)
        data_row.define_important_columns columns

        @rows << data_row
      end
    end

    def parse(data)
      if File.exist? data
        options.suggest_sep_file(data)
        csv = CSV.read(data, options.hash)
        raise "Wrong CSV" if csv == []
      else
        csv = CSV.parse(data, options.hash)
      end
      csv
    end

    private

    attr_writer :data, :options
  end
end
