# frozen_string_literal: true

module ShopifyCloud
  class StatusController < ActionController::Base
    def status
      render(json: Status.to_h)
    end
  end
end
