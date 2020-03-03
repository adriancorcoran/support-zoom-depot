json.title "Customers who bought '#{@product.title}'"
json.orders @product.orders, partial: "orders/order", as: :order