# frozen_string_literal: true

require_relative 'spec_helper'

# scope for all specs
module CSVJoin
  describe 'Comparator' do
    before :each do
      @comparator = Comparator.new
    end
    it 'finds the difference in slightly modified tables from one source' do
      left = "id,client,price\n" \
             "11,Test,100.0\n" \
             "02,Fest,150.0\n" \
             "13,Best,200.0"
      right = "id,client,price\n" \
              "11,Test,100.0\n" \
              "01,Test,100.0\n" \
              "12,Fest,100.0\n" \
              "13,Best,200.0"

      # @comparator.columns_to_compare = 'client=client,price=price'
      expect(@comparator.compare(left, right)).to eq(
        "id,client,price,diff,id,client,price\n" \
        "11,Test,100.0,===,11,Test,100.0\n" \
        '02,Fest,150.0,==>,"","",""' + "\n" \
        '"","","",<==,01,Test,100.0' + "\n" \
        '"","","",<==,12,Fest,100.0' + "\n" \
        "13,Best,200.0,===,13,Best,200.0\n"
      )
    end
    it 'finds the difference in different tables' do
      left = "id,client,price\n" \
             "11,Test,100.0\n" \
             "12,Fest,150.0\n" \
             "16,ZesZ,500.0\n" \
             "13,Best,200.0\n" \
             "15,Zest,500.0\n"

      right = "name,payment_date,amount\n" \
              "Test,2020-04-15,100.0\n" \
              "ZesZ,2020-05-06,500.0\n" \
              "Best,2020-05-01,200.0\n" \
              "Gest,2020-05-06,100.0\n" \
              "Zest,2020-05-06,500.0\n"

      @comparator.columns_to_compare = 'client=name,price=amount'
      res = @comparator.compare(left, right)
      expect(res).to eq(
        "id,client,price,diff,name,payment_date,amount\n" \
        "11,Test,100.0,===,Test,2020-04-15,100.0\n" \
        '12,Fest,150.0,==>,"","",""' + "\n" \
        "16,ZesZ,500.0,===,ZesZ,2020-05-06,500.0\n" \
        "13,Best,200.0,===,Best,2020-05-01,200.0\n" \
        '"","","",<==,Gest,2020-05-06,100.0' + "\n" \
        "15,Zest,500.0,===,Zest,2020-05-06,500.0\n"
      )
    end
    it 'can parse column param' do
      @comparator.columns_to_compare = 'client=name,amount~price'
      @comparator.compare("client,amount\nsdasd,100", "name,price\nsdasd,100")
      # c.set_default_column_names

      expect(@comparator.left.columns).to eq(%w[client amount])
      expect(@comparator.right.columns).to eq(%w[name price])
      expect(@comparator.left.weights).to eq([1, 0])
    end

    it 'works with tsv' do
      tmpfiles("A\tB\n1\t2", "A\tB\n1\t2") do |file_left, file_right|
        expect(@comparator.compare(file_left, file_right)).to eq "A\tB\tdiff\tA\tB\n1\t2\t===\t1\t2\n"
      end
    end

    it 'works with multiline csv' do
      tmpfiles(
        "A,B\nL0,0\n\"Multi\nL1\",1\nL2,2\nL3,3",
        "A,C\nL0,0\n\"Multi\nL1\",1\nL3,33"
      ) do |file_left, file_right|
        expect(@comparator.compare(file_left, file_right)).to eq(
          "A,B,diff,A,C\nL0,0,===,L0,0\n" \
          "\"Multi\nL1\",1,===,\"Multi\nL1\",1\n" \
          "L2,2,==>,\"\",\"\"\nL3,3,===,L3,33\n"
        )
      end
    end

    it 'returns all matches for identical tables' do
      data = "id,name\n1,Alice\n2,Bob"
      expect(@comparator.compare(data, data)).to eq(
        "id,name,diff,id,name\n" \
        "1,Alice,===,1,Alice\n" \
        "2,Bob,===,2,Bob\n"
      )
    end

    it 'returns all left-only when tables have no common rows' do
      left = "id,name\n1,Alice\n2,Bob"
      right = "id,name\n3,Charlie\n4,Dave"
      result = @comparator.compare(left, right)
      expect(result).to include("==>")
      expect(result).to include("<==")
      expect(result).not_to include("===")
    end

    it 'handles single row tables that match' do
      left = "col\nval"
      right = "col\nval"
      expect(@comparator.compare(left, right)).to eq(
        "col,diff,col\nval,===,val\n"
      )
    end

    it 'handles single row tables that differ' do
      left = "col\nA"
      right = "col\nB"
      expect(@comparator.compare(left, right)).to eq(
        "col,diff,col\n" \
        'A,==>,""' + "\n" \
        '"",<==,B' + "\n"
      )
    end

    it 'handles left table with more rows than right' do
      left = "x\n1\n2\n3"
      right = "x\n1"
      expect(@comparator.compare(left, right)).to eq(
        "x,diff,x\n" \
        "1,===,1\n" \
        '2,==>,""' + "\n" \
        '3,==>,""' + "\n"
      )
    end

    it 'handles right table with more rows than left' do
      left = "x\n1"
      right = "x\n1\n2\n3"
      expect(@comparator.compare(left, right)).to eq(
        "x,diff,x\n" \
        "1,===,1\n" \
        '"",<==,2' + "\n" \
        '"",<==,3' + "\n"
      )
    end

    it 'works with semicolon-separated files' do
      tmpfiles("A;B\n1;2\n3;4", "A;B\n1;2\n5;6") do |file_left, file_right|
        expect(@comparator.compare(file_left, file_right)).to eq(
          "A;B;diff;A;B\n" \
          "1;2;===;1;2\n" \
          "3;4;==>;\"\";\"\"\n" \
          "\"\";\"\";<==;5;6\n"
        )
      end
    end

    it 'handles values with Unicode characters' do
      left = "name,city\nАлиса,Москва\nBob,Лондон"
      right = "name,city\nАлиса,Москва\nChris,Париж"
      expect(@comparator.compare(left, right)).to eq(
        "name,city,diff,name,city\n" \
        "Алиса,Москва,===,Алиса,Москва\n" \
        'Bob,Лондон,==>,"",""' + "\n" \
        '"","",<==,Chris,Париж' + "\n"
      )
    end

    it 'handles values containing commas inside quotes' do
      left = "name,desc\n\"Smith, John\",hello"
      right = "name,desc\n\"Smith, John\",hello"
      expect(@comparator.compare(left, right)).to eq(
        "name,desc,diff,name,desc\n" \
        "\"Smith, John\",hello,===,\"Smith, John\",hello\n"
      )
    end

    it 'handles empty string values in cells' do
      left = "a,b\n,val\nfoo,"
      right = "a,b\n,val\nfoo,"
      expect(@comparator.compare(left, right)).to eq(
        "a,b,diff,a,b\n" \
        ",val,===,,val\n" \
        "foo,,===,foo,\n"
      )
    end

    it 'uses only specified columns for comparison when columns_to_compare is set' do
      left = "id,name,score\n1,Alice,100\n2,Bob,200"
      right = "id,name,score\n1,Alice,999\n2,Bob,888"
      @comparator.columns_to_compare = 'name=name'
      expect(@comparator.compare(left, right)).to eq(
        "id,name,score,diff,id,name,score\n" \
        "1,Alice,100,===,1,Alice,999\n" \
        "2,Bob,200,===,2,Bob,888\n"
      )
    end

    it 'handles weak (~) comparison operator' do
      left = "a,b\n1,X\n2,Y"
      right = "a,b\n1,X\n2,Y"
      @comparator.columns_to_compare = 'a~a'
      @comparator.compare(left, right)
      expect(@comparator.left.weights).to eq([0])
    end

    it 'handles tables with many columns' do
      headers = (1..10).map { |i| "col#{i}" }.join(",")
      row = (1..10).map(&:to_s).join(",")
      left = "#{headers}\n#{row}"
      right = "#{headers}\n#{row}"
      result = @comparator.compare(left, right)
      expect(result).to include("===")
    end

    it 'handles duplicate rows in both tables' do
      left = "x\nA\nA\nB"
      right = "x\nA\nB\nB"
      result = @comparator.compare(left, right)
      expect(result).to include("===")
      expect(result.scan("==>").size).to eq(1)
      expect(result.scan("<==").size).to eq(1)
    end
  end
end
