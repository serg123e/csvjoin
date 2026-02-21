# frozen_string_literal: true

require 'optparse'

module CSVJoin
  # performs cli functionality
  class App
    def run(argv)
      options = Options.new
      files, columns_spec = parse_options(argv, options)
      return if files.nil?

      result = run_comparison(options, files, columns_spec)
      write_output(result, options.output_file)
    rescue StandardError => e
      warn "Error: #{e.message}"
    end

    private

    def run_comparison(options, files, columns_spec)
      comparator = CSVJoin::Comparator.new(options)
      comparator.columns_to_compare = columns_spec if columns_spec
      comparator.compare(files[0], files[1])
    end

    def write_output(result, output_file)
      if output_file
        File.write(output_file, result)
      else
        puts result
      end
    end

    def build_parser(options)
      show_help = false
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: csvjoin2 [options] FILE1 FILE2 [COL1=COL2,COL3~COL4]"
        add_banner_text(opts)
        add_file_options(opts, options)
        add_comparison_options(opts, options)

        opts.on("-h", "--help", "Show this help") do
          show_help = true
        end
      end
      [parser, -> { show_help }]
    end

    def add_banner_text(opts)
      opts.separator ""
      opts.separator "Joins two CSV files by comparing specified columns."
      opts.separator "If no columns specified, uses columns with the same name in both files."
      opts.separator ""
      opts.separator "Column operators:"
      opts.separator "  =    strict match (e.g. client=name)"
      opts.separator "  ~    weak match (e.g. client~name)"
      opts.separator ""
      opts.separator "Options:"
    end

    def add_file_options(opts, options)
      opts.on("-o", "--output FILE", "Write output to FILE instead of stdout") do |file|
        options.output_file = file
      end
      opts.on("--sep SEPARATOR", "Set separator for both input files (default: auto-detect)") do |sep|
        options.col_sep = sep
      end
      opts.on("--sep1 SEPARATOR", "Set separator for first input file") do |sep|
        options.col_sep = sep
      end
      opts.on("--sep2 SEPARATOR", "Set separator for second input file") do |sep|
        options.col_sep_right = sep
      end
      opts.on("--out-sep SEPARATOR", "Set separator for output CSV (default: same as first file)") do |sep|
        options.output_sep = sep
      end
    end

    def add_comparison_options(opts, options)
      opts.on("-i", "--ignore-case", "Case-insensitive comparison") do
        options.ignore_case = true
      end
    end

    def parse_options(argv, options)
      parser, help_requested = build_parser(options)
      remaining = parser.parse(argv)

      if help_requested.call || remaining.length < 2
        puts parser
        return [nil, nil]
      end

      [remaining[0..1], remaining[2]]
    rescue OptionParser::InvalidOption => e
      warn "Error: #{e.message}"
      [nil, nil]
    end
  end
end
