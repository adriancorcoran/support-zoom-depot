# frozen_string_literal: true

require 'action_controller/log_subscriber'

module ShopifyCloud
  class ShopifyControllerLogSubscriber < ActionController::LogSubscriber
    def self.remove_framework_default_subscriptions
      ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
        next unless subscriber.is_a?(ActionController::LogSubscriber)
        ActiveSupport::Notifications.notifier.listeners_for("start_processing.action_controller").each do |listener|
          if listener.instance_variable_get('@delegate') == subscriber
            ActiveSupport::Notifications.unsubscribe(listener)
          end
        end
      end
    end

    # overloaded to have params JSONified
    def start_processing(event)
      return unless logger.info?

      payload = event.payload
      params  = { params: payload[:params].except(*INTERNAL_PARAMS) }
      format  = payload[:format]
      format  = format.to_s.upcase if format.is_a?(Symbol)

      info("Processing by #{payload[:controller]}##{payload[:action]} as #{format}")
      info("  Parameters: #{params.to_json}") unless params.empty?
    end
  end
end
