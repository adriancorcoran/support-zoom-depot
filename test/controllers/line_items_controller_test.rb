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

    assert_select '.Polaris-Header-Title h1', 'The Catalogue'
    assert_select '.Polaris-Layout.store', 1
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
    # can't send the cart id to the line item creator as line_items sill set a new cart id
    # when we add the product, need to get the last line_item to get its id
    product_id = products(:ruby).id
    params = {
      product_id: product_id 
    }
    post line_items_url, params: params
    new_line_item = LineItem.order(id: :asc).last
    assert_equal 1, LineItem.find_by(id: new_line_item).quantity
    post line_items_url, params: params
    post line_items_url, params: params
    assert_equal 3, LineItem.find_by(id: new_line_item).quantity
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
    patch line_item_url(@line_item), params: { line_item: { product_id: @line_item.product_id } }
    assert_redirected_to line_item_url(@line_item)
  end

  test "should destroy line_item" do
    assert_difference('LineItem.count', -1) do
      delete line_item_url(@line_item)
    end

    assert_redirected_to carts_url
  end

  test "should create line_item via ajax" do
    assert_difference('LineItem.count') do
      post line_items_url, params: { product_id: products(:ruby).id }, xhr: true
    end

    assert_response :success
    assert_match /<p class=\\"Polaris-Navigation__Item line-item-highlight/, @response.body
  end

  test "should delete line_item" do
    product_id = products(:ruby).id
    params = {
      product_id: product_id 
    }
    post line_items_url, params: params
    new_line_item = LineItem.order(id: :asc).last
    assert_equal 1, LineItem.find_by(id: new_line_item).quantity
    delete line_item_url(new_line_item.id)
    assert_raises(ActiveRecord::RecordNotFound) do
      LineItem.find(new_line_item.id)
    end
  end
  
end
