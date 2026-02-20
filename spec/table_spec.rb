# frozen_string_literal: true

require 'rspec'

module CSVJoin
  describe 'Table' do
    it 'parses CSV string and returns headers' do
      opts = Options.new
      table = Table.new("name,age\nAlice,30\nBob,25", opts)
      expect(table.headers).to eq(%w[name age])
    end

    it 'generates empty_row with correct size' do
      opts = Options.new
      table = Table.new("a,b,c\n1,2,3", opts)
      expect(table.empty_row).to eq(['', '', ''])
    end

    it 'generates empty_row matching header count for single-column table' do
      opts = Options.new
      table = Table.new("x\n1", opts)
      expect(table.empty_row).to eq([''])
    end

    it 'prepares DataRow objects from CSV data' do
      opts = Options.new
      table = Table.new("a,b\n1,2\n3,4", opts)
      table.define_important_columns(%w[a])
      table.prepare_rows
      expect(table.rows.size).to eq(2)
      expect(table.rows.first).to be_a(DataRow)
    end

    it 'assigns important columns to each DataRow during prepare_rows' do
      opts = Options.new
      table = Table.new("a,b\n1,2", opts)
      table.define_important_columns(%w[a])
      table.prepare_rows
      expect(table.rows.first.columns).to eq(%w[a])
    end

    it 'parses file with tab separator' do
      tmpfiles("A\tB\n1\t2", "X\tY\n3\t4") do |file_left, _file_right|
        opts = Options.new
        table = Table.new(file_left, opts)
        expect(table.headers).to eq(%w[A B])
        expect(opts.col_sep).to eq("\t")
      end
    end

    it 'parses file with semicolon separator' do
      tmpfiles("A;B\n1;2", "X;Y\n3;4") do |file_left, _file_right|
        opts = Options.new
        table = Table.new(file_left, opts)
        expect(table.headers).to eq(%w[A B])
        expect(opts.col_sep).to eq(";")
      end
    end

    it 'raises error for empty CSV file' do
      tmpfiles("", "x\n1") do |file_left, _file_right|
        opts = Options.new
        expect { Table.new(file_left, opts) }.to raise_error(RuntimeError)
      end
    end

    it 'initializes columns and weights as empty arrays' do
      opts = Options.new
      table = Table.new("a\n1", opts)
      expect(table.columns).to eq([])
      expect(table.weights).to eq([])
    end

    it 'supports add_column via ImportantColumns module' do
      opts = Options.new
      table = Table.new("a,b\n1,2", opts)
      table.add_column("a", 1)
      table.add_column("b", 0)
      expect(table.columns).to eq(%w[a b])
      expect(table.weights).to eq([1, 0])
    end
  end
end
