# frozen_string_literal: true

require 'rspec'

# Real-world reconciliation scenarios
module CSVJoin
  describe 'Reconciliation scenarios' do
    before :each do
      @comparator = Comparator.new
    end

    context 'bank reconciliation (book vs bank statement)' do
      it 'matches book entries against bank statement by counterparty and amount' do
        # Бухгалтерская книга (книга учёта)
        book = "date,counterparty,amount,account\n" \
               "2024-01-10,Supplier A,5000.00,60\n" \
               "2024-01-12,Supplier B,3200.00,60\n" \
               "2024-01-15,Client X,-15000.00,62\n" \
               "2024-01-18,Supplier C,750.00,60\n" \
               "2024-01-20,Tax Office,12000.00,68"

        # Банковская выписка
        statement = "value_date,beneficiary,debit,bank_ref\n" \
                    "2024-01-11,Supplier A,5000.00,REF001\n" \
                    "2024-01-13,Supplier B,3200.00,REF002\n" \
                    "2024-01-16,Client X,-15000.00,REF003\n" \
                    "2024-01-20,Tax Office,12000.00,REF005"

        @comparator.columns_to_compare = 'counterparty=beneficiary,amount=debit'
        result = @comparator.compare(book, statement)

        expect(result).to include("===")
        # Supplier C есть в книге, но нет в выписке (платёж не прошёл)
        expect(result).to include("Supplier C")
        expect(result).to include("==>")
        # Все остальные сошлись
        expect(result.scan("===").size).to eq(4)
        expect(result.scan("==>").size).to eq(1)
        expect(result.scan("<==").size).to eq(0)
      end

      it 'detects unrecorded bank fees in statement' do
        book = "ref,payee,sum\n" \
               "001,Rent,50000\n" \
               "002,Salary,120000"

        statement = "ref,payee,sum\n" \
                    "001,Rent,50000\n" \
                    "002,Salary,120000\n" \
                    "003,Bank Fee,500\n" \
                    "004,Bank Fee,300"

        result = @comparator.compare(book, statement)
        # Bank fees only in statement — right-only
        expect(result.scan("<==").size).to eq(2)
        expect(result.scan("===").size).to eq(2)
      end
    end

    context 'invoice vs payment reconciliation' do
      it 'matches invoices to payments by client and amount' do
        invoices = "inv_no,client_name,inv_amount\n" \
                   "INV-001,Alpha LLC,10000\n" \
                   "INV-002,Beta Corp,25000\n" \
                   "INV-003,Gamma Inc,7500\n" \
                   "INV-004,Delta Ltd,3000"

        payments = "pay_ref,payer,pay_amount\n" \
                   "PAY-101,Alpha LLC,10000\n" \
                   "PAY-102,Gamma Inc,7500\n" \
                   "PAY-103,Delta Ltd,3000"

        @comparator.columns_to_compare = 'client_name=payer,inv_amount=pay_amount'
        result = @comparator.compare(invoices, payments)

        # Beta Corp не оплатила — left-only
        expect(result).to include("Beta Corp")
        expect(result.scan("==>").size).to eq(1)
        expect(result.scan("===").size).to eq(3)
      end

      it 'detects amount mismatch as separate rows (partial payment)' do
        # Строгое сравнение: "10000" != "8000" — не совпадёт
        invoices = "client,amount\nAlpha,10000\nBeta,5000"
        payments = "client,amount\nAlpha,8000\nBeta,5000"

        result = @comparator.compare(invoices, payments)
        # Alpha 10000 и Alpha 8000 не совпадают — обе уходят в diff
        expect(result).to include("Beta")
        expect(result.scan("===").size).to eq(1) # только Beta
      end
    end

    context 'numeric precision differences' do
      it 'treats 100.0 and 100.00 as different strings' do
        left = "name,amount\nAlice,100.0"
        right = "name,amount\nAlice,100.00"

        result = @comparator.compare(left, right)
        # Строковое сравнение: "100.0" != "100.00"
        expect(result).not_to include("===")
      end

      it 'matches when only comparing name (ignoring amount precision)' do
        left = "name,amount\nAlice,100.0"
        right = "name,amount\nAlice,100.00"

        @comparator.columns_to_compare = 'name=name'
        result = @comparator.compare(left, right)
        # Сравниваем только по name — совпадает
        expect(result).to include("===")
        expect(result).to include("100.0")
        expect(result).to include("100.00")
      end
    end

    context 'duplicate transactions' do
      it 'matches duplicate payments one-to-one' do
        # Два одинаковых платежа одному поставщику
        book = "vendor,amount\nSupplier A,1000\nSupplier A,1000\nSupplier B,2000"
        bank = "vendor,amount\nSupplier A,1000\nSupplier A,1000\nSupplier B,2000"

        result = @comparator.compare(book, bank)
        expect(result.scan("===").size).to eq(3)
        expect(result).not_to include("==>")
        expect(result).not_to include("<==")
      end

      it 'detects extra duplicate on one side' do
        book = "vendor,amount\nSupplier A,1000\nSupplier A,1000\nSupplier A,1000"
        bank = "vendor,amount\nSupplier A,1000\nSupplier A,1000"

        result = @comparator.compare(book, bank)
        expect(result.scan("===").size).to eq(2)
        expect(result.scan("==>").size).to eq(1) # лишний дубль в книге
      end
    end

    context 'leading zeros in identifiers' do
      it 'treats 001 and 1 as different when comparing as strings' do
        invoices = "inv_id,amount\n001,5000\n002,3000"
        payments = "inv_id,amount\n1,5000\n2,3000"

        result = @comparator.compare(invoices, payments)
        # "001" != "1" — ни одна строка не совпадёт
        expect(result).not_to include("===")
      end
    end

    context 'special characters in company names' do
      it 'matches names with apostrophes and ampersands' do
        left = "name,sum\n\"O'Brien & Co.\",5000\n\"Smith\",3000"
        right = "name,sum\n\"O'Brien & Co.\",5000\n\"Smith\",3000"

        result = @comparator.compare(left, right)
        expect(result.scan("===").size).to eq(2)
      end

      it 'matches names with quotes inside quoted fields' do
        left = "name,sum\n\"\"\"Рога и копыта\"\" ООО\",10000"
        right = "name,sum\n\"\"\"Рога и копыта\"\" ООО\",10000"

        result = @comparator.compare(left, right)
        expect(result.scan("===").size).to eq(1)
      end

      it 'matches names with Umlauts and diacritics' do
        left = "vendor,amount\nMüller GmbH,2500\nCafé René,800"
        right = "vendor,amount\nMüller GmbH,2500\nCafé René,800"

        result = @comparator.compare(left, right)
        expect(result.scan("===").size).to eq(2)
      end
    end

    context 'reversed transaction order' do
      it 'aligns transactions regardless of order difference' do
        # Бухгалтерия: хронологический порядок
        book = "client,amount\nAlpha,1000\nBeta,2000\nGamma,3000"
        # Банк: обратный хронологический порядок
        bank = "client,amount\nGamma,3000\nBeta,2000\nAlpha,1000"

        result = @comparator.compare(book, bank)
        # LCS должен найти общую подпоследовательность
        expect(result).to include("===")
        # Все три есть в обеих таблицах, но порядок различается
        match_count = result.scan("===").size
        left_only = result.scan("==>").size
        right_only = result.scan("<==").size
        # В сумме: каждая строка либо matched, либо split
        expect(match_count + left_only).to be >= 3
        expect(match_count + right_only).to be >= 3
      end
    end

    context 'large reconciliation with few differences' do
      it 'correctly identifies 2 discrepancies among 50 matching rows' do
        matching_rows = (1..50).map { |i| "Client#{i},#{i * 1000}" }.join("\n")
        left = "name,amount\n#{matching_rows}\nExtra1,9999"
        right = "name,amount\n#{matching_rows}\nExtra2,8888"

        result = @comparator.compare(left, right)
        expect(result.scan("===").size).to eq(50)
        expect(result.scan("==>").size).to eq(1)
        expect(result.scan("<==").size).to eq(1)
      end
    end

    context 'weak comparison for fuzzy matching' do
      it 'uses strict (=) for amount and weak (~) for name' do
        invoices = "client,amount\nAlpha,1000\nBeta,2000"
        payments = "payer,sum\nAlpha,1000\nBeta,2000"

        @comparator.columns_to_compare = 'client~payer,amount=sum'
        result = @comparator.compare(invoices, payments)

        expect(result.scan("===").size).to eq(2)
        expect(@comparator.left.weights).to eq([0, 1])
        expect(@comparator.right.weights).to eq([0, 1])
      end
    end

    context 'tables with completely different column structures' do
      it 'reconciles 1C export vs bank CSV with column mapping' do
        # Экспорт из 1С
        accounting = "Номер,Контрагент,Сумма,Счёт\n" \
                     "1,ООО Ромашка,50000,60\n" \
                     "2,ИП Иванов,12000,60\n" \
                     "3,ООО Василёк,8500,60"

        # Выписка из банка
        bank = "N,Получатель,Дебет,Дата\n" \
               "101,ООО Ромашка,50000,2024-01-15\n" \
               "102,ИП Иванов,12000,2024-01-16"

        @comparator.columns_to_compare = 'Контрагент=Получатель,Сумма=Дебет'
        result = @comparator.compare(accounting, bank)

        expect(result.scan("===").size).to eq(2)
        # ООО Василёк не прошёл по банку
        expect(result).to include("ООО Василёк")
        expect(result.scan("==>").size).to eq(1)
      end
    end

    context 'TSV reconciliation from different systems' do
      it 'reconciles tab-separated exports' do
        tmpfiles(
          "invoice\tamount\tstatus\nINV001\t5000\tpaid\nINV002\t3000\tpaid\nINV003\t7000\tpending",
          "invoice\tamount\tpay_date\nINV001\t5000\t2024-01-10\nINV002\t3000\t2024-01-12\nINV004\t1000\t2024-01-15"
        ) do |file_left, file_right|
          @comparator.columns_to_compare = 'invoice=invoice,amount=amount'
          result = @comparator.compare(file_left, file_right)

          expect(result.scan("===").size).to eq(2)
          expect(result).to include("INV003") # left-only
          expect(result).to include("INV004") # right-only
        end
      end
    end

    context 'multiline addresses in accounting data' do
      it 'handles multiline fields during reconciliation' do
        tmpfiles(
          "vendor,address,amount\nAlpha,\"123 Main St\nSuite 4\",5000\nBeta,\"456 Oak Ave\",3000",
          "vendor,address,amount\nAlpha,\"123 Main St\nSuite 4\",5000\nGamma,\"789 Elm Rd\",2000"
        ) do |file_left, file_right|
          @comparator.columns_to_compare = 'vendor=vendor,amount=amount'
          result = @comparator.compare(file_left, file_right)

          expect(result.scan("===").size).to eq(1)
          expect(result.scan("==>").size).to eq(1)
          expect(result.scan("<==").size).to eq(1)
        end
      end
    end

    context 'single column reconciliation' do
      it 'compares lists of transaction IDs' do
        processed = "txn_id\nTX001\nTX002\nTX003\nTX004\nTX005"
        confirmed = "txn_id\nTX001\nTX003\nTX005"

        result = @comparator.compare(processed, confirmed)
        expect(result.scan("===").size).to eq(3)
        expect(result.scan("==>").size).to eq(2) # TX002, TX004 не подтверждены
      end
    end

    context 'empty values in key columns' do
      it 'matches rows where comparison column is empty on both sides' do
        left = "id,vendor,amount\n1,,500\n2,Alpha,1000"
        right = "id,vendor,amount\n3,,500\n4,Alpha,1000"

        @comparator.columns_to_compare = 'vendor=vendor,amount=amount'
        result = @comparator.compare(left, right)
        # Пустой vendor + 500 совпадает с пустым vendor + 500
        expect(result.scan("===").size).to eq(2)
      end

      it 'does not match empty vendor against non-empty vendor' do
        left = "vendor,amount\n,500"
        right = "vendor,amount\nAlpha,500"

        result = @comparator.compare(left, right)
        expect(result).not_to include("===")
      end
    end
  end
end
