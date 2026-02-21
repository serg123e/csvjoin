# frozen_string_literal: true

require 'rspec'
require 'fileutils'

describe 'CSVJoinApp' do
  before do
    @app = CSVJoin::App.new
  end

  context 'when no params given' do
    it 'prints help' do
      expect { @app.run([]) }.to output(/Usage:/).to_stdout
    end
  end

  context 'when -h given' do
    it 'prints help' do
      expect { @app.run(['-h']) }.to output(/Usage:/).to_stdout
    end
  end

  context 'when 2 params given' do
    it 'compare files' do
      tmpfiles("A\tB\n1\t2", "A\tB\n1\t2") do |filename1, filename2|
        expect { @app.run([filename1, filename2]) }.to output("A\tB\tdiff\tA\tB\n1\t2\t===\t1\t2\n").to_stdout
      end
    end
  end

  context 'when 3 params given' do
    it 'compare files with on specified columns' do
      tmpfiles("A\tB\n1\t2", "A\tB\n1\t33") do |filename1, filename2|
        expect { @app.run([filename1, filename2, "A=A"]) }.to output("A\tB\tdiff\tA\tB\n1\t2\t===\t1\t33\n").to_stdout
      end
    end
  end

  context 'when --help given' do
    it 'prints help' do
      expect { @app.run(['--help']) }.to output(/Usage:/).to_stdout
    end
  end

  context 'when 1 param given' do
    it 'prints help' do
      expect { @app.run(['onlyone']) }.to output(/Usage:/).to_stdout
    end
  end

  context 'when -h is among other params' do
    it 'prints help' do
      expect { @app.run(['file1', 'file2', '-h']) }.to output(/Usage:/).to_stdout
    end
  end

  context 'when comparing CSV files' do
    it 'compares comma-separated files' do
      tmpfiles("A,B\n1,2\n3,4", "A,B\n1,2\n5,6") do |filename1, filename2|
        expect { @app.run([filename1, filename2]) }.to output(/===/).to_stdout
      end
    end
  end

  context 'when comparing files with differences' do
    it 'shows ==> for left-only rows' do
      tmpfiles("A\tB\n1\t2\n3\t4", "A\tB\n1\t2") do |filename1, filename2|
        expect { @app.run([filename1, filename2]) }.to output(/==>/).to_stdout
      end
    end

    it 'shows <== for right-only rows' do
      tmpfiles("A\tB\n1\t2", "A\tB\n1\t2\n3\t4") do |filename1, filename2|
        expect { @app.run([filename1, filename2]) }.to output(/<==/).to_stdout
      end
    end
  end

  context 'with -o option' do
    it 'writes output to file' do
      tmpfiles("A,B\n1,2", "A,B\n1,2") do |filename1, filename2|
        output_file = "/tmp/csvjoin_test_output_#{Process.pid}.csv"
        begin
          @app.run(['-o', output_file, filename1, filename2])
          expect(File.exist?(output_file)).to be true
          content = File.read(output_file)
          expect(content).to include("===")
        ensure
          FileUtils.rm_f(output_file)
        end
      end
    end
  end

  context 'with --ignore-case option' do
    it 'matches case-insensitively' do
      tmpfiles("name\nAlice", "name\nalice") do |filename1, filename2|
        expect { @app.run(['-i', filename1, filename2]) }.to output(/===/).to_stdout
      end
    end
  end

  context 'with --out-sep option' do
    it 'uses specified output separator' do
      tmpfiles("A,B\n1,2", "A,B\n1,2") do |filename1, filename2|
        expect { @app.run(['--out-sep', ';', filename1, filename2]) }.to output(/;/).to_stdout
      end
    end
  end

  context 'with --sep option' do
    it 'uses specified separator for both files' do
      tmpfiles("A;B\n1;2", "A;B\n1;2") do |filename1, filename2|
        expect { @app.run(['--sep', ';', filename1, filename2]) }.to output(/===/).to_stdout
      end
    end
  end

  context 'with --sep1 option' do
    it 'uses specified separator for left file' do
      tmpfiles("A;B\n1;2", "A;B\n1;2") do |filename1, filename2|
        expect { @app.run(['--sep1', ';', filename1, filename2]) }.to output(/===/).to_stdout
      end
    end
  end

  context 'with --sep2 option' do
    it 'uses specified separator for right file' do
      tmpfiles("A,B\n1,2", "A\tB\n1\t2") do |filename1, filename2|
        expect { @app.run(['--sep2', "\t", filename1, filename2]) }.to output(/===/).to_stdout
      end
    end
  end

  context 'error handling' do
    it 'prints error for nonexistent file' do
      expect { @app.run(['/tmp/nonexistent.csv', '/tmp/also_nonexistent.csv']) }.to output(/Error:/).to_stderr
    end

    it 'prints error for invalid column spec' do
      tmpfiles("a,b\n1,2", "a,b\n1,2") do |filename1, filename2|
        expect { @app.run([filename1, filename2, 'x=y=z']) }.to output(/Error:/).to_stderr
      end
    end

    it 'prints error for invalid option' do
      expect { @app.run(['--invalid-option']) }.to output(/Error:/).to_stderr
    end
  end

  context 'help content' do
    it 'documents the -o option' do
      expect { @app.run(['-h']) }.to output(/-o/).to_stdout
    end

    it 'documents the -i option' do
      expect { @app.run(['-h']) }.to output(/-i/).to_stdout
    end
  end
end
