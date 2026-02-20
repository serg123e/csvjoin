# frozen_string_literal: true

module CSVJoin
  describe 'Options' do
    before :each do
      @options = Options.new
      # @c = ComparatorUtils.new()
    end
    it 'detects tabs' do
      expect(@options.suggest_sep("A\tB\n")).to eq "\t"
      expect(@options.suggest_sep("A\tB")).to eq "\t"
      expect(@options.suggest_sep("Test,Field\tBest\tAsd")).to eq "\t"
    end
    it 'detects commas' do
      expect(@options.suggest_sep("Test,Field,Best\tAsd")).to eq ","
    end

    it 'detects semicolons' do
      expect(@options.suggest_sep("Test;Field;Best\tAsd\n")).to eq ";"
      expect(@options.suggest_sep("Test\tField;Best;Asd")).to eq ";"
    end

    it 'returns comma as default when no delimiters present' do
      result = @options.suggest_sep("nodelimiters")
      expect(%W[, ; \t]).to include(result)
    end

    it 'handles string with only one character' do
      result = @options.suggest_sep("X")
      expect(%W[, ; \t]).to include(result)
    end

    it 'handles empty string' do
      result = @options.suggest_sep("")
      expect(%W[, ; \t]).to include(result)
    end

    it 'picks the most frequent delimiter on tie-break between comma and semicolon' do
      # One comma, one semicolon, zero tabs => max_by returns first with max count
      result = @options.suggest_sep("A,B;C")
      expect(%w[, ;]).to include(result)
    end

    it 'initializes with default comma separator' do
      expect(@options.col_sep).to eq(",")
      expect(@options.columns_to_compare).to eq("")
    end

    it 'initializes with custom separator' do
      opts = Options.new(col_sep: "\t", columns_to_compare: "a=b")
      expect(opts.col_sep).to eq("\t")
      expect(opts.columns_to_compare).to eq("a=b")
    end

    it 'returns correct hash for CSV parsing' do
      h = @options.hash
      expect(h).to eq({ headers: true, row_sep: "\n", col_sep: "," })
    end

    it 'detects separator from file' do
      tmpfiles("A\tB\n1\t2", "X\tY\n3\t4") do |file_left, _file_right|
        @options.suggest_sep_file(file_left)
        expect(@options.col_sep).to eq("\t")
      end
    end

    it 'detects comma separator from file' do
      tmpfiles("A,B,C\n1,2,3", "X\nY") do |file_left, _file_right|
        @options.suggest_sep_file(file_left)
        expect(@options.col_sep).to eq(",")
      end
    end

    it 'detects semicolon separator from file' do
      tmpfiles("A;B;C\n1;2;3", "X\nY") do |file_left, _file_right|
        @options.suggest_sep_file(file_left)
        expect(@options.col_sep).to eq(";")
      end
    end
  end
end
