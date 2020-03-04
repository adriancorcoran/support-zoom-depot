# frozen_string_literal: true
require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  setup do
    @order = orders(:one)
    @order_fill_in_details = {
      name: 'Adrian Corcoran',
      address: 'Gillstown, Kilglass, Strokestown, Co. Roscommon F42F972',
      email: 'adriancorcoran36@gmail.com',
    }
  end

  test "visiting the index" do
    visit orders_url
    # assert_selector "h1", text: "Orders"
    # find the start of the JSON output
    assert_text "[{"
  end

  # no interface yet - just JSON
  # test "creating a Order" do
  #   visit orders_url
  #   click_on "New Order"

  #   fill_in "Address", with: @order.address
  #   fill_in "Email", with: @order.email
  #   fill_in "Name", with: @order.name
  #   fill_in "Pay type", with: @order.pay_type
  #   click_on "Create Order"

  #   assert_text "Order was successfully created"
  #   click_on "Back"
  # end

  # no interface yet - just JSON
  # test "updating a Order" do
  #   visit orders_url
  #   click_on "Edit", match: :first

  #   fill_in "Address", with: @order.address
  #   fill_in "Email", with: @order.email
  #   fill_in "Name", with: @order.name
  #   fill_in "Pay type", with: @order.pay_type
  #   click_on "Update Order"

  #   assert_text "Order was successfully updated"
  #   click_on "Back"
  # end

  # no interface yet - just JSON
  # test "destroying a Order" do
  #   visit orders_url
  #   page.accept_confirm do
  #     click_on "Destroy", match: :first
  #   end

  #   assert_text "Order was successfully destroyed"
  # end

  test "check credit card is displayed" do
    visit store_index_url
    click_on "Add to Cart", match: :first
    click_on "My Cart", match: :first
    click_on "Checkout"
    fill_in 'order_name', with: @order_fill_in_details[:name]
    fill_in 'order_address', with: @order_fill_in_details[:address]
    fill_in 'order_email', with: @order_fill_in_details[:email]
    assert_no_selector "#order_credit_card_number"
    assert_no_selector "#order_expiration_date"
    select 'Credit card', from: 'pay_type'
    assert_selector "#order_credit_card_number"
    assert_selector "#order_expiration_date"
  end

  test "check routing number is displayed" do
    visit store_index_url
    click_on "Add to Cart", match: :first
    click_on "My Cart", match: :first
    click_on "Checkout"
    fill_in 'order_name', with: @order_fill_in_details[:name]
    fill_in 'order_address', with: @order_fill_in_details[:address]
    fill_in 'order_email', with: @order_fill_in_details[:email]
    assert_no_selector "#order_routing_number"
    assert_no_selector "#order_account_number"
    select 'Check', from: 'pay_type'
    assert_selector "#order_routing_number"
    assert_selector "#order_account_number"
  end

  test "check purchase order is displayed" do
    visit store_index_url
    click_on "Add to Cart", match: :first
    click_on "My Cart", match: :first
    click_on "Checkout"
    fill_in 'order_name', with: @order_fill_in_details[:name]
    fill_in 'order_address', with: @order_fill_in_details[:address]
    fill_in 'order_email', with: @order_fill_in_details[:email]
    assert_no_selector "#order_po_number"
    select 'Purchase order', from: 'pay_type'
    assert_selector "#order_po_number"
  end

  test "check no payment method is displayed" do
    visit store_index_url
    click_on "Add to Cart", match: :first
    click_on "My Cart", match: :first
    click_on "Checkout"
    fill_in 'order_name', with: @order_fill_in_details[:name]
    fill_in 'order_address', with: @order_fill_in_details[:address]
    fill_in 'order_email', with: @order_fill_in_details[:email]
    assert_no_selector "#order_po_number"
    select 'Purchase order', from: 'pay_type'
    assert_selector "#order_po_number"
    select 'Select a payment method', from: 'pay_type'
    assert_no_selector "#order_po_number"
    select 'Purchase order', from: 'pay_type'
    assert_selector "#order_po_number"
  end
end
