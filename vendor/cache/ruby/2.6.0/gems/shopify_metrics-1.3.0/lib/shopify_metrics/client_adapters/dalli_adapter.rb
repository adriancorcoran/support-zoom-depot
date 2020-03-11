# frozen_string_literal: true
require "dalli"

module ShopifyMetrics
  module ClientAdapters
    module DalliAdapter
      INSTRUMENTED_COMMANDS = %i(
        add
        append
        decr
        delete
        get
        incr
        prepend
        replace
        set
      ).to_set.freeze

      ERRORS = [
        Dalli::NetworkError,
        Dalli::RingError,
        Timeout::Error,
      ]

      def request(op, *args)
        measure_latency = INSTRUMENTED_COMMANDS.member?(op) && !multi?
        ShopifyMetrics.instrument("dalli", *ERRORS, measure_latency: measure_latency) do
          super(op, *args)
        end
      end
    end
  end
end

Dalli::Server.prepend(ShopifyMetrics::ClientAdapters::DalliAdapter)
