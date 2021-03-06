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
  end
end
