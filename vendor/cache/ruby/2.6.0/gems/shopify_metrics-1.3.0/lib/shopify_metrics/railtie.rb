# frozen_string_literal: true

module ShopifyMetrics
  class Railtie < Rails::Railtie
    config.after_initialize do
      prefix = parent_class.to_s
      if StatsD.singleton_client.is_a?(StatsD::Instrument::Client)
        # When using the new client, we replace the singleton client with a new one that has a prefix set.
        if StatsD.singleton_client.prefix.nil?
          StatsD.singleton_client = StatsD.singleton_client.clone_with_options(prefix: prefix)
        end
      else
        # When using the legacy client, set a prefix on the singleton object.
        # This can be removed once we can bump the version requirement to 3.0 or higher.
        StatsD.prefix = prefix unless StatsD.prefix
      end
    end

    initializer "shopify_metrics.initialize" do
      ActiveSupport.on_load(:action_controller) do
        if Rails.application.config.x.shopify_metrics_disable_action_controller_tags.blank?
          require 'shopify_metrics/action_controller_tags'
          ActionController::Metal.include ShopifyMetrics::ActionControllerTags
        end
      end
    end

    initializer "shopify_metrics.add_middlewares" do |app|
      if Rails.application.config.x.shopify_metrics_disable_request_metrics_middleware.blank?
        app.middleware.insert 0, ShopifyMetrics::Middlewares::RequestMetrics
      end

      if Rails.application.config.x.shopify_metrics_disable_raindrops_middleware.blank?
        app.middleware.insert 1, ShopifyMetrics::Middlewares::RaindropsMiddleware
      end

      if Rails.application.config.x.shopify_metrics_disable_sidekiq_middleware.blank?
        if defined? Sidekiq
          Sidekiq.server_middleware do |chain|
            chain.add ShopifyMetrics::Middlewares::SidekiqMetrics
          end
        end
      end

      if Rails.application.config.x.shopify_metrics_disable_puma_plugin.blank?
        if defined?(Puma)
          require 'shopify_metrics/puma_plugin_loader'
        end
      end
    end

    initializer "shopify_metrics.instrument_clients" do
      if Rails.application.config.x.shopify_metrics_disable_client_instrumentation.blank?
        ShopifyMetrics.instrument_clients
      end
    end

    def parent_class
      klass = Rails.application.class
      klass.respond_to?(:module_parent) ? klass.module_parent : klass.parent
    end
  end
end
