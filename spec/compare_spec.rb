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
      expect(@comparator.compare(left, right)).to eq("id,client,price,diff,id,client,price\n" \
                                                     "11,Test,100.0,===,11,Test,100.0\n" \
                                                     '02,Fest,150.0,==>,"","",""' + "\n" \
                                                     '"","","",<==,01,Test,100.0' + "\n" \
                                                     '"","","",<==,12,Fest,100.0' + "\n" \
                                                     "13,Best,200.0,===,13,Best,200.0\n")
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
      tmpfiles("A,B\nL0,0\n\"Multi\nL1\",1\nL2,2\nL3,3", "A,C\nL0,0\n\"Multi\nL1\",1\nL3,33") do |file_left, file_right|
        expect(@comparator.compare(file_left,
                                   file_right)).to eq "A,B,diff,A,C\nL0,0,===,L0,0\n" \
                                                      "\"Multi\nL1\",1,===,\"Multi\nL1\",1\n" \
                                                      "L2,2,==>,\"\",\"\"\nL3,3,===,L3,33\n"
      end
    end
  end
end
