# frozen_string_literal: true

module CSVJoin
  # represents one table in comparison
  class Table
    include ImportantColumns

    attr_reader :rows, :options, :data

    def initialize(source, opts)
      self.options = opts.dup
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
        data_row.define_important_columns columns, weights
        data_row.ignore_case = options.ignore_case

        @rows << data_row
      end
    end

    def file?(data)
      !data.include?("\n") && File.exist?(data)
    end

    def parse(data)
      if file?(data)
        parse_file(data)
      else
        parse_string(data)
      end
    rescue CSV::MalformedCSVError => e
      raise "Invalid CSV: #{e.message}"
    end

    def parse_file(path)
      options.suggest_sep_file(path)
      csv = CSV.read(path, **options.csv_options)
      raise "Empty CSV file: #{path}" if csv == []

      csv
    end

    def parse_string(data)
      raise "File not found: #{data}" if looks_like_filepath?(data)

      CSV.parse(data, **options.csv_options)
    end

    def looks_like_filepath?(data)
      !data.include?("\n") && (data.end_with?('.csv', '.tsv', '.txt') || data.include?(File::SEPARATOR))
    end

    private

    attr_writer :data, :options
  end
end
