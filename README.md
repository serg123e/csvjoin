# CSVJoin: Table Align & Merge tool
tool to align and merge two tables containing different parts of the same data. 

![Table join](https://www.github.com/serg123e/csvjoin/join.png)

## Installation
`$ gem install csvjoin`

## Example of use

It's a typical task in reconciliation of payments

one table with sells data, in file `sells.csv` 

    id,client,price
    13,Best,200.0
    12,Fest,150.0
    11,Test,100.0

and another with incoming payments, in `payments.csv` 

    name,payment_date,amount
    Best,2020-05-01,200.0
    Gest,2020-05-06,100.0
    Test,2020-04-15,90.0
    Test,2020-04-16,10.0

in order to check that all sells have been paid we need to compare that tables
please notice that both tables have to been ordered using the same principle (By Client Name + By Id and By Name + By Date )

`$ csvjoin table1.csv table2.csv client=name,price=amount`

    id,client,price,diff,name,payment_date,amount
    13,Best,200.0,===,Best,2020-05-01,200.0
    12,Fest,150.0,==>,"","",""
    "","","",<==,Gest,2020-05-06,100.0
    11,Test,100.0,===,Test,2020-04-15,100.0
    "","","",<==,Test,2020-04-16,10.0

now we can see that
- for 2 payments corresponding sell have been found and have assigned a sell id 
- payment from client Fest still not arrived,
- and we have a unexpected payments from Gest and Test without corresponding rows in sells.csv


