require 'test_helper'

class LineItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @line_item = line_items(:one)
  end

  test "should get index" do
    get line_items_url
    assert_response :success
  end

  test "should get new" do
    get new_line_item_url
    assert_response :success
  end

  test "should create line_item" do
    assert_difference('LineItem.count') do
      post line_items_url, params: { product_id: products(:ruby).id }
    end

    follow_redirect!

    assert_select '.Polaris-Header-Title h1', 'Your Cart'
    assert_select '.Polaris-DataTable__TableRow', @line_item.cart.line_items.count
  end

  test "should not create line_item" do
    assert_difference('LineItem.count') do
      post line_items_url, params: { product_id: products(:ruby).id }
    end
    assert_difference('LineItem.count', 0) do
      post line_items_url, params: { product_id: products(:ruby).id }
    end
  end

  test "should increase line_item quantity" do
    product_id = products(:ruby).id
    cart_id = carts(:one).id
    params = {
      :cart_id => cart_id,
      :product_id => product_id 
    }
    post line_items_url, params: params
    assert_equal 1, LineItem.find_by(product_id: product_id).quantity
    post line_items_url, params: params
    post line_items_url, params: params
    assert_equal 3, LineItem.find_by(product_id: product_id).quantity
  end

  test "should show line_item" do
    get line_item_url(@line_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_line_item_url(@line_item)
    assert_response :success
  end

  test "should update line_item" do
    patch line_item_url(@line_item), params: { line_item: { cart_id: @line_item.cart_id, product_id: @line_item.product_id } }
    assert_redirected_to line_item_url(@line_item)
  end

  test "should destroy line_item" do
    assert_difference('LineItem.count', -1) do
      delete line_item_url(@line_item)
    end

    assert_redirected_to line_items_url
  end
end
