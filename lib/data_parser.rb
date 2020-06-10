# frozen_string_literal: true

require 'csv'

module Talimer
  class DataRow < CSV::Row
    attr_accessor :comparator
    def side
      @side
    end
    def side=(p)
      @side=p
    end
    def inspect
      "#{side}:#{super}"
    end
    def eql?(other)
      self == other
    end
    def hash
      if (@comparator.columns)
        res = []
        @comparator.weights.each_with_index do |weight, index|
          from, to = @comparator.columns[index]
          if (side.eql?'right')
            field = to
          else
            field = from
          end

          if (self[field].nil?)
            warn("something wrong, #{self.inspect}, side #{side.inspect}, f'#{field}'==nil")
          end
          if weight >= 1
            res << self[field]
          else
            res << self[field]
          end
        end
        return res.hash
      else
        self.row.hash
      end

    end


    #
    # Returns +true+ if this row contains the same headers and fields in the
    # same order as +other+.
    #
    def ==(other)
      if (@comparator.columns)
        @comparator.weights.each_with_index do |weight, index|
          from, to = @comparator.columns[index]
          # warn "#{from},#{to},#{self.inspect},#{other.inspect}"
          if (self[from].nil? or other[to].nil?)
            warn "something wrong"
          end
          if weight >= 1
            #warn("#{self[from]} <1> #{other[to]}")
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
