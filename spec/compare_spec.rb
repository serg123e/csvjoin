﻿require_relative 'spec_helper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'comparator.rb')

module Tabalmer
describe 'tabalmer' do
  it 'finds the difference' do

    t1 = "id,client,price\n"+
        "11,Test,100.0"+
        "12,Fest,150.0"+
        "13,Best,200.0"


    t2 = "name,payment_date,amount\n"+
        "Test,2020-04-15,97.0\n"+
        "Best,2020-05-01,200.0\n"+
        "Gest,2020-05-06,100.0"

    expect( Comparator.compare(t1, t2) ).to eq(
          "id,name,price,diff,table2.name,payment_date,amount\n"+
          "11,Test,100.0,<=>,Test,2020-04-15,97.0"+
          "12,Fest,150.0,==>,,,"+
          "13,Best,200.0,===,Best,2020-05-01,200.0"+
          ",,,<==,Gest,2020-05-06,100.0)" )

  end
  it 'can parse column param' do
    c = Comparator.new
    c.set_columns_to_compare("client:name,amount:price")
    expect( c.columns ).to eq( [['client','name'], ['amount','price']] )
  end

  it 'works with tsv and csv' do
  end
  it 'works with multiline csv' do
  end
  it 'works with multiline csv' do
  end

end

end
