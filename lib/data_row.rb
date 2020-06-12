# frozen_string_literal: true

require 'csv'

module CSVJoin
  class DataRow < CSV::Row
    attr_accessor :columns, :weights
    attr_reader :side

    attr_writer :side

    def inspect
      "#{side}:#{super}"
    end

    def eql?(other)
      self == other
    end

    def hash
      if @columns
        res = []
        @weights.each_with_index do |weight, index|
          field = @columns[index]

          warn("something wrong, #{inspect}, side #{side.inspect}, f'#{field}'==nil") if self[field].nil?
          res << if weight >= 1
                   self[field]
                 else
                   self[field]
                 end
        end
        return res.hash
      else
        row.hash
      end
    end

    #
    # Returns +true+ if this row contains the same headers and fields in the
    # same order as +other+.
    #
    def ==(other)
      if @columns
        @weights.each_with_index do |weight, index|
          from = @columns[index]
          to = other.columns[index]
          # warn "#{from},#{to},#{self.inspect},#{other.inspect}"
          warn "something wrong" if self[from].nil? || other[to].nil?
          if weight >= 1
            # warn("#{self[from]} <1> #{other[to]}")
            return false unless self[from].eql? other[to]
          else
            # warn("#{self[from]} <0> #{other[to]}")
            return false unless self[from].eql? other[to] # "<=>"
          end
        end
        return true
      else

        return @row == other.row if other.is_a? CSV::Row

        @row == other
      end
    end
  end
end
