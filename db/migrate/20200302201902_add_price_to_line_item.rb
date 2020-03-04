# frozen_string_literal: true
class AddPriceToLineItem < ActiveRecord::Migration[6.0]
  def change
    add_column(:line_items, :price, :decimal, after: :quantity)
  end
end
