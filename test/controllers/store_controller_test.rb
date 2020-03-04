# frozen_string_literal: true
require 'test_helper'

class StoreControllerTest < ActionDispatch::IntegrationTest
  PRICE_PATTERN = /\€[,\d]+\.\d\d/

  setup do
    @products = products
  end

  test "should get index" do
    get store_index_url
    assert_response :success
    assert_select 'nav ul li', minimum: 1
    assert_select 'main .product-card', @products.size
    @products.each do |product|
      assert_select 'main h2.Polaris-Heading', product.title
    end
    assert_select '.product-card__price', PRICE_PATTERN
  end
end
