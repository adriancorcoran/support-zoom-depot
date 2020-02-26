module CurrentCart

  private

  def set_cart
    @cart = Cart.find(session[:id_cart])
  rescue ActiveRecord::RecordNotFound
    @cart = Cart.create
    session[:id_cart] = @cart.id
  end
end