require_relative 'data_parser'
module Tabalmer
  class Comparator
    def initialize
    end
    def self.compare(t1,t2)
      d1 = DataParser.parse(t1)
      d2 = DataParser.parse(t2)

      j = 0
      d1.each_with_index do|row1, i|
        if (d2[j])

        end

      end

    end
  end
end
