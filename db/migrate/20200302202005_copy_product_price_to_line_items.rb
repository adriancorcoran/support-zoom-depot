class CopyProductPriceToLineItems < ActiveRecord::Migration[6.0]
  def up
    # loop through line items and set the price
    LineItem.all.each do |line_item|
      line_item.price = Product.find_by(id: line_item.product_id).price
      line_item.save!
    end
  end
  
  def down
    # loop through line items and set the price
    LineItem.all.each do |line_item|
      line_item.price = nil
      line_item.save!
    end
  end
end
