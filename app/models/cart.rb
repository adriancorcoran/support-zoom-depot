class Cart < ApplicationRecord
  has_many :line_items, dependent: :destroy

  def add_product(product)
    current_item = line_items.find_by(product_id: product.id)
    if current_item
      current_item.quantity += 1
    else
      current_item = line_items.build(product_id: product.id)      
    end
    current_item
  end

  # get total number of items in the cart or 0
  def total_num_items
    line_items.reduce(0) { |sum, item| sum + item.quantity }     
  end

  # get total cost of items in the cart or 0
  def total_cost_items
    line_items.sum(&:total_cost_line_item)
  end
  
  # items in the cart
  def has_line_items?
    line_items.any?
  end
  
end
