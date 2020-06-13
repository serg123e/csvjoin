# frozen_string_literal: true

require_relative 'spec_helper'

module CSVJoin
  describe 'tabalmer' do
    it 'finds the difference in slightly modified tables from one source' do
      t1 = "id,client,price\n" \
           "11,Test,100.0\n" \
           "02,Fest,150.0\n" \
           "13,Best,200.0"
      t2 = "id,client,price\n" \
           "11,Test,100.0\n" \
           "01,Test,100.0\n" \
           "12,Fest,100.0\n" \
           "13,Best,200.0"

      c = Comparator.new
      expect(c.compare(t1, t2)).to eq("id,client,price,diff,id,client,price\n" \
                                               "11,Test,100.0,===,11,Test,100.0\n" \
                                               '02,Fest,150.0,==>,"","",""' + "\n" \
                                                    '"","","",<==,01,Test,100.0' + "\n" \
                                                    '"","","",<==,12,Fest,100.0' + "\n" \
                                               "13,Best,200.0,===,13,Best,200.0\n")
    end
    it 'finds the difference in different tables' do
      t1 = "id,client,price\n" \
           "11,Test,100.0\n" \
           "12,Fest,150.0\n" \
           "16,ZesZ,500.0\n" \
           "13,Best,200.0\n" \
           "15,Zest,500.0\n"

      t2 = "name,payment_date,amount\n" \
           "Test,2020-04-15,100.0\n" \
           "ZesZ,2020-05-06,500.0\n" \
           "Best,2020-05-01,200.0\n" \
           "Gest,2020-05-06,100.0\n" \
           "Zest,2020-05-06,500.0\n"

      c = Comparator.new
      c.columns_to_compare('client=name,price=amount')
      # c.lcs(t1, t2)
      res = c.compare(t1, t2)
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
      c = Comparator.new
      c.columns_to_compare('client=name,amount~price')
      expect(c.columns).to eq([%w[client name], %w[amount price]])
      expect(c.weights).to eq([1, 0])
    end

    it 'works with tsv' do
      tmpfiles("A\tB\n1\t2", "A\tB\n1\t2") do |f1, f2|
        # p Comparator.new.compare(f1,f2)
        expect(Comparator.new.compare(f1, f2)).to eq "A\tB\tdiff\tA\tB\n1\t2\t===\t1\t2\n"
        # warn("f1#{f1}, f2#{f2}")
      end
    end

    it 'works with multiline csv' do
      tmpfiles("A,B\nL0,0\n\"Multi\nL1\",1\nL2,2\nL3,3", "A,C\nL0,0\n\"Multi\nL1\",1\nL3,33") do |f1, f2|
        expect(Comparator.new.compare(f1,
                                      f2)).to eq "A,B,diff,A,C\nL0,0,===,L0,0\n\"Multi\nL1\",1,===,\"Multi\nL1\",1\nL2,2,==>,\"\",\"\"\nL3,3,===,L3,33\n"
      end
    end
  end

  describe '#intuit_col_sep' do
    before :all do
      @c = Comparator.new
    end
    it 'detects tabs' do
      expect(@c.intuit_col_sep("A\tB\n")).to eq "\t"
      expect(@c.intuit_col_sep("A\tB")).to eq "\t"
      expect(@c.intuit_col_sep("Test,Field\tBest\tAsd")).to eq "\t"
    end
    it 'detects commas' do
      expect(@c.intuit_col_sep("Test,Field,Best\tAsd")).to eq ","
    end

    it 'detects semicolons' do
      expect(@c.intuit_col_sep("Test;Field;Best\tAsd\n")).to eq ";"
      expect(@c.intuit_col_sep("Test\tField;Best;Asd")).to eq ";"
    end
  end
end
