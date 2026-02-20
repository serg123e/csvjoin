# frozen_string_literal: true

require 'rspec'

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
      # expect{@app.run([''])}.to output(/Usage:/).to_stdout
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
end
