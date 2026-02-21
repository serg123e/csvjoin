# CSVJoin2: Table Align & Merge tool
Tool to align and merge two tables containing different parts of the same data, without losing or duplication of it

![Table join](join.png?raw=true)

## Installation

From RubyGems:
```
gem install csvjoin
```

From GitHub (latest development version):
```
gem install specific_install
gem specific_install https://github.com/serg123e/csvjoin.git
```

## Usage

```
csvjoin2 [options] FILE1 FILE2 [COL1=COL2,COL3=COL4]
```

If no columns are specified, columns with the same name in both files are used for comparison.

### Options

| Option | Description |
|--------|-------------|
| `-o`, `--output FILE` | Write output to FILE instead of stdout |
| `--sep SEPARATOR` | Set separator for both input files (default: auto-detect) |
| `--sep1 SEPARATOR` | Set separator for first input file |
| `--sep2 SEPARATOR` | Set separator for second input file |
| `--out-sep SEPARATOR` | Set separator for output CSV (default: same as first file) |
| `-i`, `--ignore-case` | Case-insensitive comparison |

### Diff markers

| Marker | Meaning |
|--------|---------|
| `===` | Rows matched in both files |
| `==>` | Row exists only in the left file |
| `<==` | Row exists only in the right file |

## Example

It's a typical task when automation meets the real world and we need to join two raw tables without a unique ID present in both.
We can't join them in a SQL way and should rely on weaker criteria like name and row order.

* Migration from Excel-based accounting to an ERP, where we have several tables to join and all of them contain almost-correct-but-with-some-errors data
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

In order to check that all sales have been paid we need to compare these tables.
Please notice that both tables have to be ordered using the same principle (by client name + by id, and by name + by date).

`csvjoin2 invoices.csv payments.csv client=name,price=amount`

    invoice_id,client,price,diff,name,payment_date,amount
    13,Best,200.0,===,Best,2020-05-01,200.0
    12,Fest,150.0,==>,"","",""
    "","","",<==,Gest,2020-05-06,100.0
    11,Test,100.0,===,Test,2020-04-15,100.0
    "","","",<==,Test,2020-04-16,10.0

Now we can see that:
- 2 invoices (Best, Test) matched their payments (`===`)
- invoice for Fest has no corresponding payment (`==>`)
- payments from Gest and the second Test payment have no corresponding invoices (`<==`)


## CSVKit
There is a great suite [CSVKit](https://csvkit.readthedocs.io/en/latest/) with a lot of handy CSV tools,
including the tool `csvjoin`, but it does inner/outer joins which are not as helpful in cases like the one described above

`csvjoin --outer -c name invoices.csv payments.csv`

<pre>
    invoice_id,name,price,name2,payment_date,amount
    13,Best,200.0,Best,2020-05-01,200.0
    12,Fest,150.0,,,
    11,Test,100.0,Test,2020-04-15,100.0
    **11,Test,100.0**,Test,2020-04-16,10.0
    ,,,Gest,2020-05-06,100.0
</pre>