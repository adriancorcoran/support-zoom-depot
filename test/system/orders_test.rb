# frozen_string_literal: true
require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

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

  test "check order by routing number" do
    # get current number of orders
    current_num_orders = Order.all.size
    # travlel the path
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
    fill_in "Routing #", with: "1234456"
    fill_in "Account #", with: "789"
    # do background jobs triggered by the passed block
    perform_enqueued_jobs do
      click_button "Place Order"
    end
    # check order was created
    orders = Order.all.order(id: :asc)
    assert_equal current_num_orders + 1, orders.size
    order = orders.last
    assert_equal @order_fill_in_details[:name], order.name
    assert_equal @order_fill_in_details[:address], order.address
    assert_equal @order_fill_in_details[:email], order.email
    assert_equal "Check", order.pay_type
    assert_equal 1, order.line_items.size
    # check emails was sent (in test, this is saved in the ActionMailer::Base.deliveries array)
    mail = ActionMailer::Base.deliveries.last
    assert_equal [@order_fill_in_details[:email]], mail.to
    assert_equal 'Adrian Corcoran <adrian.corcoran@shopify.com>', mail[:from].value
    assert_equal 'We got your order!', mail.subject
  end

  test "check order by credit card" do
    # get current number of orders
    current_num_orders = Order.all.size
    # travlel the path
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

    fill_in "CC #", with: "00001111222233333"
    fill_in "Expiry", with: "13/12"
    # do background jobs triggered by the passed block
    perform_enqueued_jobs do
      click_button "Place Order"
    end
    # check order was created
    orders = Order.all.order(id: :asc)
    assert_equal current_num_orders + 1, orders.size
    order = orders.last
    assert_equal @order_fill_in_details[:name], order.name
    assert_equal @order_fill_in_details[:address], order.address
    assert_equal @order_fill_in_details[:email], order.email
    assert_equal "Credit card", order.pay_type
    assert_equal 1, order.line_items.size
    # check emails was sent (in test, this is saved in the ActionMailer::Base.deliveries array)
    mail = ActionMailer::Base.deliveries.last
    assert_equal [@order_fill_in_details[:email]], mail.to
    assert_equal 'Adrian Corcoran <adrian.corcoran@shopify.com>', mail[:from].value
    assert_equal 'We got your order!', mail.subject
  end

  test "check order by purchase order" do
    # get current number of orders
    current_num_orders = Order.all.size
    # travlel the path
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
    fill_in "PO #", with: "671524"
    # do background jobs triggered by the passed block
    perform_enqueued_jobs do
      click_button "Place Order"
    end
    # check order was created
    orders = Order.all.order(id: :asc)
    assert_equal current_num_orders + 1, orders.size
    order = orders.last
    assert_equal @order_fill_in_details[:name], order.name
    assert_equal @order_fill_in_details[:address], order.address
    assert_equal @order_fill_in_details[:email], order.email
    assert_equal "Purchase order", order.pay_type
    assert_equal 1, order.line_items.size
    # check emails was sent (in test, this is saved in the ActionMailer::Base.deliveries array)
    mail = ActionMailer::Base.deliveries.last
    assert_equal [@order_fill_in_details[:email]], mail.to
    assert_equal 'Adrian Corcoran <adrian.corcoran@shopify.com>', mail[:from].value
    assert_equal 'We got your order!', mail.subject
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

  test "check order by credit card in Irish" do
    # get current number of orders
    current_num_orders = Order.all.size
    # travlel the path
    visit store_index_url(locale: 'ga')
    click_on "Cuir sa Chairt", match: :first
    click_on "Mo Charta", match: :first
    click_on "Seiceáil Amach"
    fill_in 'order_name', with: @order_fill_in_details[:name]
    fill_in 'order_address', with: @order_fill_in_details[:address]
    fill_in 'order_email', with: @order_fill_in_details[:email]
    assert_no_selector "#order_credit_card_number"
    assert_no_selector "#order_expiration_date"
    select 'Cárta creidmheasa', from: 'pay_type'
    assert_selector "#order_credit_card_number"
    assert_selector "#order_expiration_date"

    fill_in "CC #", with: "00001111222233333"
    fill_in "Dul in éag", with: "13/12"
    # do background jobs triggered by the passed block
    perform_enqueued_jobs do
      click_button "Ordú Áit"
    end
    # check order was created
    orders = Order.all.order(id: :asc)
    assert_equal current_num_orders + 1, orders.size
    order = orders.last
    assert_equal @order_fill_in_details[:name], order.name
    assert_equal @order_fill_in_details[:address], order.address
    assert_equal @order_fill_in_details[:email], order.email
    assert_equal "Credit card", order.pay_type
    assert_equal 1, order.line_items.size
    # check emails was sent (in test, this is saved in the ActionMailer::Base.deliveries array)
    mail = ActionMailer::Base.deliveries.last
    assert_equal [@order_fill_in_details[:email]], mail.to
    assert_equal 'Adrian Corcoran <adrian.corcoran@shopify.com>', mail[:from].value
    assert_equal 'Fuair ​​muid d\'ordú!', mail.subject
  end
end
