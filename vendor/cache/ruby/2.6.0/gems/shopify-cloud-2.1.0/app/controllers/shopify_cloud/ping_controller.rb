# frozen_string_literal: true

module ShopifyCloud
  class PingController < ActionController::Metal
    def ping
      self.response_body = 'pong'
    end
  end
end
