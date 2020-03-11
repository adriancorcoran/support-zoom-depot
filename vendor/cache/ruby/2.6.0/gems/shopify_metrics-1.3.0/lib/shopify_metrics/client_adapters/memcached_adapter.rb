# frozen_string_literal: true
require "memcached"

module ShopifyMetrics
  module ClientAdapters
    module MemcachedAdapter
      # Supports only arturnn/memcached @1.8, not @master
      # Patch only single key, O(1) time complexity operations.
      INSTRUMENTED_COMMANDS = %i(
        add
        append
        decrement
        delete
        exist
        increment
        prepend
        replace
        set
        single_cas
        single_get
      ).freeze

      NO_LATENCY_INSTRUMENTED_COMMANDS = %i(
        multi_cas
        multi_get
      ).freeze

      ERRORS = [
        Memcached::ATimeoutOccurred,
        Memcached::ConnectionFailure,
        Memcached::ConnectionSocketCreateFailure,
        Memcached::Failure,
        Memcached::HostnameLookupFailure,
        Memcached::MemoryAllocationFailure,
        Memcached::ProtocolError,
        Memcached::ReadFailure,
        Memcached::ServerEnd,
        Memcached::ServerError,
        Memcached::ServerIsMarkedDead,
        Memcached::SomeErrorsWereReported,
        Memcached::SystemError,
        Memcached::UnknownReadFailure,
        Memcached::WriteFailure,
      ]

      INSTRUMENTED_COMMANDS.each do |meth|
        define_method(meth) do |*args, &block|
          ShopifyMetrics.instrument("memcached", *ERRORS, measure_latency: true) do
            super(*args, &block)
          end
        end
      end

      NO_LATENCY_INSTRUMENTED_COMMANDS.each do |meth|
        define_method(meth) do |*args, &block|
          ShopifyMetrics.instrument("memcached", *ERRORS, measure_latency: false) do
            super(*args, &block)
          end
        end
      end

      private :single_get, :single_cas, :multi_get, :multi_cas
    end
  end
end

Memcached.prepend(ShopifyMetrics::ClientAdapters::MemcachedAdapter)
