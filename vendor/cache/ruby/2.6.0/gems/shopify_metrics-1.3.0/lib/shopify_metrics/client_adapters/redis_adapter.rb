# frozen_string_literal: true
require "redis"

module ShopifyMetrics
  module ClientAdapters
    module RedisAdapter
      INSTRUMENTED_COMMANDS = %i(
        append
        bitfield
        blpop
        brpop
        brpoplpush
        decr
        decrby
        exists
        expire
        expireat
        get
        getbit
        getset
        hexists
        hget
        hincrby
        hincrbyfloat
        hlen
        hscan
        hset
        hsetnx
        hstrlen
        incr
        incrby
        incrbyfloat
        llen
        lpop
        lpush
        lpushx
        move
        object
        persist
        pexpire
        pexpireat
        pfadd
        pfcount
        ping
        psetex
        pttl
        randomkey
        readonly
        readwrite
        rename
        renamenx
        rpop
        rpoplpush
        rpush
        rpushx
        scan
        scard
        set
        setbit
        setex
        setnx
        sismember
        smove
        spop
        sscan
        strlen
        time
        ttl
        type
        unlink
        unwatch
        watch
        xlen
        zcard
        zscan
        zscore
      ).to_set.freeze

      ERRORS = [
        Redis::CannotConnectError,
        Redis::ConnectionError,
        Redis::TimeoutError,
      ]

      def process(commands, &block)
        ShopifyMetrics.instrument("redis", *ERRORS, measure_latency: constant_time_complexity?(commands)) do
          super(commands, &block)
        end
      end

      def constant_time_complexity?(commands)
        commands.size == 1 && INSTRUMENTED_COMMANDS.member?(commands[0][0])
      end
    end
  end
end

Redis::Client.prepend(ShopifyMetrics::ClientAdapters::RedisAdapter)
