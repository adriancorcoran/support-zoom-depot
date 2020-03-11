# frozen_string_literal: true

require 'active_support/subscriber'

module ShopifyCloud
  class LogSubscriber < ActiveSupport::Subscriber
    attach_to :action_controller

    def process_action(event)
      application_logs = application_custom_logs(event)
      return unless application_logs

      Rails.logger.info("  Request Information: #{application_logs.to_json}")
    end

    private

    def application_custom_logs(event)
      Rails.application.config.shopify_cloud.custom_logs&.call(event)
    end
  end
end
