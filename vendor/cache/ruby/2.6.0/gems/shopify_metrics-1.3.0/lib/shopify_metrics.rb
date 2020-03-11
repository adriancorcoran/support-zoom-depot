# frozen_string_literal: true
require "statsd-instrument"
require "shopify_metrics/version"
require "shopify_metrics/puma_stats"
require "shopify_metrics/railtie"
require "shopify_metrics/tags"
require "shopify_metrics/raindrops_monitor"

module ShopifyMetrics
  extend Tags

  module Middlewares
    autoload :RequestMetrics, 'shopify_metrics/middlewares/request_metrics_middleware'
    autoload :RaindropsMiddleware, 'shopify_metrics/middlewares/raindrops_middleware'
    autoload :SidekiqMetrics, 'shopify_metrics/middlewares/sidekiq_metrics_middleware'
  end

  module Jobs
    autoload :SidekiqPerformanceMetrics, 'shopify_metrics/jobs/sidekiq_performance_metrics'
  end

  def self.logger
    @logger || Rails.logger
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.instrument_clients
    %i(dalli memcached redis).each do |adapter|
      begin
        require "shopify_metrics/client_adapters/#{adapter}_adapter"
      rescue LoadError
        nil
      end
    end
  end

  def self.instrument(adapter, *err_classes, measure_latency:)
    tags = if StatsD.singleton_client.prefix
      { namespace: StatsD.singleton_client.prefix.to_s }
    else
      {}
    end
    tags = ShopifyMetrics.add_application_tags(tags)
    StatsD.increment(
      "shopify_metrics.client.#{adapter}.query_count",
      no_prefix: true,
      tags: tags
    )
    begin
      result = nil
      if measure_latency
        StatsD.distribution(
          "shopify_metrics.client.#{adapter}.latency",
          no_prefix: true,
          tags: tags
        ) do
          result = yield
        end
      else
        result = yield
      end
      result
    rescue *err_classes
      StatsD.increment(
        "shopify_metrics.client.#{adapter}.error_count",
        no_prefix: true,
        tags: tags
      )
      raise
    end
  end
end
