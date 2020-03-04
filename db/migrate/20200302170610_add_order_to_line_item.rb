# frozen_string_literal: true
class AddOrderToLineItem < ActiveRecord::Migration[6.0]
  def change
    add_reference(:line_items, :order, null: true, foreign_key: true, after: :quantity)
  end
end
