# frozen_string_literal: true

require 'rspec'
require 'tempfile'
require 'simplecov'
require 'rspec/simplecov'

SimpleCov.minimum_coverage 100
SimpleCov.start

def tmpfiles(data1, data2)
  Tempfile.create do |f1|
    Tempfile.create do |f2|
      f1.write(data1)
      f1.close

      f2.write(data2)
      f2.close

      yield f1.path, f2.path
      File.unlink(f1.path)
      File.unlink(f2.path)
    end
  end
end

require File.join(File.dirname(__FILE__), '..', 'lib', 'comparator.rb')
