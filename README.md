# CSVJoin: Table Align & Merge tool
tool to align and merge two tables containing different parts of the same data. 
It's a typical task when the critical data have been entered manually by operators, in reconciliation of payments


####  sells.csv:

    id,client,price
    11,Test,100.0
    12,Fest,150.0
    13,Best,200.0

#### payments.csv:

    name,payment_date,amount
    Test,2020-04-15,97.0
    Best,2020-05-01,200.0
    Gest,2020-05-06,100.0


`$ csvjoin table1.csv table2.csv client=name,price=amount`

    id,name,price,diff,table2.name,payment_date,amount
    11,Test,100.0,<=>,Test,2020-04-15,97.0
    12,Fest,150.0,==>,,,
    13,Best,200.0,   ,Best,2020-05-01,200.0
    ,,,<==,Gest,2020-05-06,100.0

now we can see that
- client Test had paid wrong amount (TODO), 
- Fest still not paid at all,
- and we have a unexpected payment from Gest without corresponding row in sells.csv

