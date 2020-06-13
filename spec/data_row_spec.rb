# frozen_string_literal: true

require 'rspec'

module CSVJoin
  describe 'DataRow' do
    before :each do
      @row = DataRow.new(%w[A B], %w[1 2])
      @row.side = LEFT
      @row.columns = ["A"]
      @row.weights = [1]

      @row2 = DataRow.new(%w[Z X], %w[1 2])
      @row2.side = RIGHT
      @row2.columns = ["Z"]
      @row2.weights = [1]

      @row3 = DataRow.new(%w[K L], %w[3 4])
      @row2.side = RIGHT
      @row3.columns = ["K"]
      @row3.weights = [1]
    end

    it 'inspect' do
      expect(@row.inspect).to eq "#{LEFT}:#<CSVJoin::DataRow \"A\":\"1\" \"B\":\"2\">"
    end

    it '==' do
      expect(@row == @row2).to be true
    end

    it '!=' do
      expect(@row != @row3).to be true
      expect(@row == @row3).to be false
    end

    it '#hash' do
      expect(@row.hash == @row2.hash).to be true
    end

    it '#eql?' do
      expect(@row.eql?(@row2)).to be true
    end
  end
end
