# frozen_string_literal: true
require "puma/configuration"

module ShopifyMetrics
  module PumaPluginLoader
    def initialize(user_options = {}, default_options = {}, &block)
      super

      @default_dsl.plugin(:shopify_metrics)
    end
  end
end

Puma::Configuration.prepend(ShopifyMetrics::PumaPluginLoader)
