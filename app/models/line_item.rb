class LineItem < ApplicationRecord
  belongs_to :product
  belongs_to :cart

  # get total cost of a single line items
  def total_cost_line_item
    quantity * product.price
  end  

end
