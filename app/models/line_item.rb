class LineItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product, optional: true
  belongs_to :cart

  # get total cost of a single line items
  def total_cost_line_item
    quantity * product.price
  end  

end
