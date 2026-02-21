# frozen_string_literal: true

# Ability to differ important for comparison columns from others
module ImportantColumns
  attr_reader :columns, :weights

  def add_column(name, weight = 1)
    @columns << name
    @weights << weight
  end

  def define_important_columns(columns, weights = [])
    @columns = columns
    @weights = weights.empty? ? [*[1] * @columns.size] : weights
  end

  private

  attr_writer :columns, :weights
end
