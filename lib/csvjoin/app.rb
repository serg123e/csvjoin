# frozen_string_literal: true

module CSVJoin
  # performs cli functionality
  class App
    def run(argv)
      if argv.length < 2 || (argv.include? "-h") || (argv.include? "--help")
        help
      else
        comparator = CSVJoin::Comparator.new
        file_left, file_right, params = argv
        comparator.set_columns_to_compare(params) if params
        puts comparator.compare(file_left, file_right)
      end
    end

    private

    def help
      puts "Usage: csvjoin2 FILE1 FILE2 [ColumnA1=ColumnA2,ColumnB1=ColumnB2]"
      puts "Joins two CSV files looking for same values in specified columns. "
      puts "If no columns specified by default it will use columns with the same name in both files"
    end
  end
end
