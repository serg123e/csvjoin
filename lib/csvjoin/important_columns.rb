# frozen_string_literal: true

module ImportantColumns
  attr_reader :columns, :weights

  def add_column(name, weight = 1)
    @columns << name
    @weights << weight
  end

  def important_columns(cols)
    @columns = cols
    @weights = [*[1] * @columns.size]
  end

  private

  attr_writer :columns, :weights
end
