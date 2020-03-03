# keeping this to refer back to

# json.extract! order, :id, :name, :address, :email, :pay_type, :created_at, :updated_at
# json.url order_url(order, format: :json)

json.id "Order ##{order.id}"
json.shipped_to "Shipped to #{order.address}"
json.line_items order.line_items do |item|
  json.product item.product.title
  json.quantity item.quantity
  json.price item.price
end
json.customer_name order.name
json.customer_email order.email
json.pay_type order.pay_type