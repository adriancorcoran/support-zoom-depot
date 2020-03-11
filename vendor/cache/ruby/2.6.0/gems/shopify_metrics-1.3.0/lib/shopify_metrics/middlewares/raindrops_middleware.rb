# frozen_string_literal: true
require "raindrops"
require_relative "../raindrops_monitor"

module ShopifyMetrics
  module Middlewares
    class RaindropsMiddleware
      RATE = 1.second

      def initialize(app)
        @app = app
        @last_captured = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def call(env)
        # If the thread is running in the master process emitting metrics, we
        # don't need to do it inline here. We do it inline for backwards
        # compatibility but the performance hit is noticeable, e.g. we don't do
        # this in core.
        capture_metrics unless RaindropsMonitor.running?
        @app.call(env)
      end

      private

      def capture_metrics
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        if @last_captured + RATE < now
          RaindropsMonitor.capture_metrics
          @last_captured = now
        end
      end
    end
  end
end
