# frozen_string_literal: true
require 'test_helper'

class OrderMailerTest < ActionMailer::TestCase
  setup do
    @order = orders(:one)
  end

  test "received" do
    mail = OrderMailer.received(@order)
    assert_equal "We got your order!", mail.subject
    assert_equal [@order.email], mail.to
    assert_equal ["adrian.corcoran@shopify.com"], mail.from
    assert_match(/x Programming Ruby 1.9/, mail.body.encoded)
  end

  test "shipped" do
    mail = OrderMailer.shipped(@order)
    assert_equal "Your order is on the way!", mail.subject
    assert_equal [@order.email], mail.to
    assert_equal ["adrian.corcoran@shopify.com"], mail.from
    assert_match("Thanks for shopping with us", mail.body.encoded)
  end
end
