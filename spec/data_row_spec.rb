# frozen_string_literal: true

require 'rspec'

module CSVJoin
  describe 'DataRow' do
    before :each do
      @row = DataRow.new(%w[A B], %w[1 2])
      # @row.side = LEFT
      @row.define_important_columns(["A"])

      @row2 = DataRow.new(%w[Z X], %w[1 2])
      # @row2.side = RIGHT
      @row2.define_important_columns(["Z"])

      @row3 = DataRow.new(%w[K L], %w[3 4])
      # @row2.side = RIGHT
      @row3.define_important_columns(["K"])
    end

    it 'inspect' do
      expect(@row.inspect).to eq "noside:#<CSVJoin::DataRow \"A\":\"1\" \"B\":\"2\">"
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

    it 'returns different hash for different values' do
      expect(@row.hash).not_to eq(@row3.hash)
    end

    it 'compares with multiple important columns' do
      row_a = DataRow.new(%w[X Y], %w[1 2])
      row_a.define_important_columns(%w[X Y])

      row_b = DataRow.new(%w[X Y], %w[1 2])
      row_b.define_important_columns(%w[X Y])

      expect(row_a == row_b).to be true
      expect(row_a.hash).to eq(row_b.hash)
    end

    it 'detects inequality when one of multiple important columns differs' do
      row_a = DataRow.new(%w[X Y], %w[1 2])
      row_a.define_important_columns(%w[X Y])

      row_b = DataRow.new(%w[X Y], %w[1 99])
      row_b.define_important_columns(%w[X Y])

      expect(row_a == row_b).to be false
      expect(row_a.hash).not_to eq(row_b.hash)
    end

    it 'treats nil values as equal when both sides have nil' do
      row_a = DataRow.new(%w[A], [nil])
      row_a.define_important_columns(["A"])

      row_b = DataRow.new(%w[A], [nil])
      row_b.define_important_columns(["A"])

      expect(row_a == row_b).to be true
      expect(row_a.hash).to eq(row_b.hash)
    end

    it 'treats nil as different from a string value' do
      row_a = DataRow.new(%w[A], [nil])
      row_a.define_important_columns(["A"])

      row_b = DataRow.new(%w[A], ["value"])
      row_b.define_important_columns(["A"])

      expect(row_a == row_b).to be false
    end

    it 'treats empty string as different from nil' do
      row_a = DataRow.new(%w[A], [""])
      row_a.define_important_columns(["A"])

      row_b = DataRow.new(%w[A], [nil])
      row_b.define_important_columns(["A"])

      expect(row_a == row_b).to be false
    end

    it 'handles rows with Unicode values' do
      row_a = DataRow.new(%w[name], ["Алиса"])
      row_a.define_important_columns(["name"])

      row_b = DataRow.new(%w[name], ["Алиса"])
      row_b.define_important_columns(["name"])

      expect(row_a == row_b).to be true
      expect(row_a.hash).to eq(row_b.hash)
    end

    it 'compares only important columns, ignoring others' do
      row_a = DataRow.new(%w[id name score], %w[1 Alice 100])
      row_a.define_important_columns(["name"])

      row_b = DataRow.new(%w[id name score], %w[999 Alice 999])
      row_b.define_important_columns(["name"])

      expect(row_a == row_b).to be true
    end

    it 'uses add_column with weight' do
      row_a = DataRow.new(%w[A B], %w[1 2])
      row_a.define_important_columns([])
      row_a.add_column("A", 1)
      row_a.add_column("B", 0)

      expect(row_a.columns).to eq(%w[A B])
      expect(row_a.weights).to eq([1, 0])
    end

    context 'weak (~) comparison' do
      it 'matches rows that differ only in weak columns' do
        row_a = DataRow.new(%w[id amount], %w[1 100])
        row_a.define_important_columns([])
        row_a.add_column("id", 1)
        row_a.add_column("amount", 0)

        row_b = DataRow.new(%w[id amount], %w[1 999])
        row_b.define_important_columns([])
        row_b.add_column("id", 1)
        row_b.add_column("amount", 0)

        expect(row_a == row_b).to be true
        expect(row_a.hash).to eq(row_b.hash)
      end

      it 'does not match rows that differ in strict columns' do
        row_a = DataRow.new(%w[id amount], %w[1 100])
        row_a.define_important_columns([])
        row_a.add_column("id", 1)
        row_a.add_column("amount", 0)

        row_b = DataRow.new(%w[id amount], %w[2 100])
        row_b.define_important_columns([])
        row_b.add_column("id", 1)
        row_b.add_column("amount", 0)

        expect(row_a == row_b).to be false
        expect(row_a.hash).not_to eq(row_b.hash)
      end

      it 'matches all rows when all columns are weak' do
        row_a = DataRow.new(%w[x y], %w[1 2])
        row_a.define_important_columns([])
        row_a.add_column("x", 0)
        row_a.add_column("y", 0)

        row_b = DataRow.new(%w[x y], %w[9 9])
        row_b.define_important_columns([])
        row_b.add_column("x", 0)
        row_b.add_column("y", 0)

        expect(row_a == row_b).to be true
        expect(row_a.hash).to eq(row_b.hash)
      end

      it 'works with ignore_case on strict columns' do
        row_a = DataRow.new(%w[name amount], %w[Alice 100])
        row_a.define_important_columns([])
        row_a.add_column("name", 1)
        row_a.add_column("amount", 0)
        row_a.ignore_case = true

        row_b = DataRow.new(%w[name amount], %w[alice 999])
        row_b.define_important_columns([])
        row_b.add_column("name", 1)
        row_b.add_column("amount", 0)
        row_b.ignore_case = true

        expect(row_a == row_b).to be true
        expect(row_a.hash).to eq(row_b.hash)
      end
    end

    context 'case-insensitive comparison' do
      it 'matches values with different case when ignore_case is true' do
        row_a = DataRow.new(%w[name], ["Alice"])
        row_a.define_important_columns(["name"])
        row_a.ignore_case = true

        row_b = DataRow.new(%w[name], ["alice"])
        row_b.define_important_columns(["name"])
        row_b.ignore_case = true

        expect(row_a == row_b).to be true
      end

      it 'produces same hash for different case when ignore_case is true' do
        row_a = DataRow.new(%w[name], ["Alice"])
        row_a.define_important_columns(["name"])
        row_a.ignore_case = true

        row_b = DataRow.new(%w[name], ["ALICE"])
        row_b.define_important_columns(["name"])
        row_b.ignore_case = true

        expect(row_a.hash).to eq(row_b.hash)
      end

      it 'does not match different case when ignore_case is false' do
        row_a = DataRow.new(%w[name], ["Alice"])
        row_a.define_important_columns(["name"])
        row_a.ignore_case = false

        row_b = DataRow.new(%w[name], ["alice"])
        row_b.define_important_columns(["name"])
        row_b.ignore_case = false

        expect(row_a == row_b).to be false
      end

      it 'handles nil values with ignore_case true' do
        row_a = DataRow.new(%w[A], [nil])
        row_a.define_important_columns(["A"])
        row_a.ignore_case = true

        row_b = DataRow.new(%w[A], [nil])
        row_b.define_important_columns(["A"])
        row_b.ignore_case = true

        expect(row_a == row_b).to be true
        expect(row_a.hash).to eq(row_b.hash)
      end
    end
  end
end
