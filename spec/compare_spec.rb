# frozen_string_literal: true

require_relative 'spec_helper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'comparator.rb')

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
                                               "02,Fest,150.0,==>,,,\n" \
                                                          ",,,<==,01,Test,100.0\n" \
                                                          ",,,<==,12,Fest,100.0\n" \
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
      warn "res====\n" + res
      expect(res).to eq(
        "id,client,price,diff,name,payment_date,amount\n" \
        "11,Test,100.0,===,Test,2020-04-15,100.0\n" \
        "12,Fest,150.0,==>,,,\n" \
        "16,ZesZ,500.0,===,ZesZ,2020-05-06,500.0\n" \
        "13,Best,200.0,===,Best,2020-05-01,200.0\n" \
                   ",,,<==,Gest,2020-05-06,100.0\n" \
        "15,Zest,500.0,===,Zest,2020-05-06,500.0\n"
      )
    end
    it 'can parse column param' do
      c = Comparator.new
      c.columns_to_compare('client=name,amount~price')
      expect(c.columns).to eq([%w[client name], %w[amount price]])
      expect(c.weights).to eq([1, 0])
    end

    it 'works with tsv and csv' do
    end

    it 'works with multiline csv' do
    end
    it 'works with multiline csv' do
    end
  end
end
