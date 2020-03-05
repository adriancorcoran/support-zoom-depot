# frozen_string_literal: true
class OrderMailer < ApplicationMailer
  default from: 'Adrian Corcoran <adrian.corcoran@shopify.com>'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.received.subject
  #
  def received(order)
    @order = order
    mail(to: order.email, subject: "We got your order!")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.shipped.subject
  #
  def shipped(order)
    @order = order
    mail(to: order.email, subject: "Your order is on the way!")
  end
end
