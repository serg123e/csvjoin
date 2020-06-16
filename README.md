# CSVJoin2: Table Align & Merge tool
tool to align and merge two tables containing different parts of the same data, without loosing or duplication of it

![Table join](join.png?raw=true)

## Installation
`gem install csvjoin`

## Example of use

It's a typical task, when the automation meets with real world, and we need to join two raw tables without unique ID presented in both.
So we can't join them in SQL way and should rely on some weaker criterias like name and the order of tables.

* Migration from Excel based accounting to some ERP, and we have several tables to join and all of them contains almost-real-but-with-some-errors data 
* Balance sheet account reconciliation
* Bank reconciliation, looking for the difference between a book balance and bank balance
* Invoices & Payments Reconciliation

one table with invoices, in file `invoices.csv` 

    invoice_id,client,price
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

`csvjoin2 invoices.csv payments.csv client=name,price=amount`

    invoice_id,client,price,diff,name,payment_date,amount
    13,Best,200.0,===,Best,2020-05-01,200.0
    12,Fest,150.0,==>,"","",""
    "","","",<==,Gest,2020-05-06,100.0
    11,Test,100.0,===,Test,2020-04-15,100.0
    "","","",<==,Test,2020-04-16,10.0

now we can see that
- for 2 payments corresponding invoices have been found and have assigned a invoice id 
- payment from client Fest still not arrived,
- and we have a unexpected payments from Gest and Test without corresponding rows in sells.csv


## CSVKit
There is a great suite CSVKit (https://csvkit.readthedocs.io/en/latest/) with a lot of handful csv tools,
including the tool `csvjoin` but what it's doing inner/outer join which is not so helpfull in case like described above

`csvjoin --outer -c name invoices.csv payments.csv`

<pre>
    invoice_id,name,price,name2,payment_date,amount
    13,Best,200.0,Best,2020-05-01,200.0
    12,Fest,150.0,,,
    11,Test,100.0,Test,2020-04-15,100.0
    **11,Test,100.0**,Test,2020-04-16,10.0
    ,,,Gest,2020-05-06,100.0
</pre>