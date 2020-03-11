# frozen_string_literal: true

module ShopifyCloud
  class Engine < ::Rails::Engine
    isolate_namespace ShopifyCloud

    config.shopify_cloud = ActiveSupport::OrderedOptions.new
    config.shopify_cloud.disable_asset_host = false
    config.shopify_cloud.asset_uploader = ActiveSupport::OrderedOptions.new
    config.shopify_cloud.asset_uploader.directory = nil
    config.shopify_cloud.asset_uploader.cache_control = 'public'

    initializer :shopify_buffered_logger, before: :initialize_logger do |app|
      next unless ENV['RAILS_LOG_TO_STDOUT']

      ShopifyControllerLogSubscriber.remove_framework_default_subscriptions
      ShopifyControllerLogSubscriber.attach_to(:action_controller)

      logger = BufferedLogger.new(STDOUT)
      logger.formatter = app.config.log_formatter

      app.config.logger = ActiveSupport::TaggedLogging.new(logger)
      app.config.middleware.insert(0, BufferedLogger::Middleware, app.config.logger)
    end

    initializer :asset_host do |app|
      next if app.config.consider_all_requests_local || app.config.shopify_cloud.disable_asset_host

      host = "https://cdn.shopify.com/shopifycloud/#{ShopifyCloud::AssetUploader.asset_directory}"
      app.config.action_controller.asset_host = host
      if app.config.respond_to?(:action_mailer)
        app.config.action_mailer.asset_host = host
      end
    end

    initializer :active_job_buffered_logger do
      next unless ENV['RAILS_LOG_TO_STDOUT']

      ActiveSupport.on_load(:active_job) do
        include ActiveJobBufferedLogging
      end
    end
  end
end
