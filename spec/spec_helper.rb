# frozen_string_literal: true

require 'rspec'
require 'tempfile'
require 'simplecov'
require 'rspec/simplecov'

SimpleCov.minimum_coverage 100
SimpleCov.start

def tmpfiles(data1, data2)
  Tempfile.create do |file1|
    Tempfile.create do |file2|
      file1.write(data1)
      file1.close

      file2.write(data2)
      file2.close

      yield file1.path, file2.path
      File.unlink(file1.path)
      File.unlink(file2.path)
    end
  end
end

require_relative '../lib/csvjoin/comparator'
