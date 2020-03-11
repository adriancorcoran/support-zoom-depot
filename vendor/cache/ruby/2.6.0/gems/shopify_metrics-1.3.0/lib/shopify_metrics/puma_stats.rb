# frozen_string_literal: true

module ShopifyMetrics
  class PumaStats
    WORKER_KEYS = [:running, :backlog, :pool_capacity, :max_threads].freeze

    WorkerStatus = Struct.new(:name, *WORKER_KEYS)

    def initialize(stats)
      @stats = stats
    end

    def clustered?
      @stats.key?(:workers)
    end

    def desired_workers
      @stats.fetch(:workers, 0)
    end

    def booted_workers
      @stats.fetch(:booted_workers, 0)
    end

    def workers
      if clustered?
        @stats[:worker_status].map do |worker_status|
          name = "worker_#{worker_status.fetch(:index, 0)}"
          WorkerStatus.new(name, *worker_status.fetch(:last_status, {}).fetch_values(*WORKER_KEYS) { 0 })
        end
      else
        [
          WorkerStatus.new("master", *@stats.fetch_values(*WORKER_KEYS) { 0 }),
        ]
      end
    end
  end
end
