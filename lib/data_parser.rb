require 'csv'
module Tabalmer

  class DataParser
    def self.parse(t)
      CSV.parse(t, headers: true)
      # if (t.instance_of?String)
    end
  end

end
