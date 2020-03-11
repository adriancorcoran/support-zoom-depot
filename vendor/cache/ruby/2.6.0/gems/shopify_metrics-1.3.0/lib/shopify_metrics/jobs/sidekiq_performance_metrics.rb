# frozen_string_literal: true

module ShopifyMetrics
  module Jobs
    class SidekiqPerformanceMetrics
      include Sidekiq::Worker

      SIDEKIQ_PREFIX = 'sidekiq_'
      METRICS_SAMPLE_RATE = 1.0

      def perform
        sidekiq_stats = Sidekiq::Stats.new
        tags = ShopifyMetrics.application_tags
        StatsD.gauge("#{SIDEKIQ_PREFIX}scheduled", sidekiq_stats.scheduled_size,
          tags: tags, sample_rate: METRICS_SAMPLE_RATE)
        StatsD.gauge("#{SIDEKIQ_PREFIX}retry", sidekiq_stats.retry_size,
          tags: tags, sample_rate: METRICS_SAMPLE_RATE)
        StatsD.gauge("#{SIDEKIQ_PREFIX}dead", sidekiq_stats.dead_size,
          tags: tags, sample_rate: METRICS_SAMPLE_RATE)
        StatsD.gauge("#{SIDEKIQ_PREFIX}enqueued", sidekiq_stats.enqueued,
          tags: tags, sample_rate: METRICS_SAMPLE_RATE)
        StatsD.gauge("#{SIDEKIQ_PREFIX}processes", sidekiq_stats.processes_size,
          tags: tags, sample_rate: METRICS_SAMPLE_RATE)
        StatsD.gauge("#{SIDEKIQ_PREFIX}workers", sidekiq_stats.workers_size,
          tags: tags, sample_rate: METRICS_SAMPLE_RATE)
        StatsD.gauge("#{SIDEKIQ_PREFIX}processed", sidekiq_stats.processed,
          tags: tags, sample_rate: METRICS_SAMPLE_RATE)
        StatsD.gauge("#{SIDEKIQ_PREFIX}failed", sidekiq_stats.failed,
          tags: tags, sample_rate: METRICS_SAMPLE_RATE)

        sidekiq_stats.queues.each do |queue_name, job_count|
          StatsD.gauge("#{SIDEKIQ_PREFIX}queue_size", job_count,
            tags: ShopifyMetrics.add_application_tags(job_queue: queue_name), sample_rate: METRICS_SAMPLE_RATE)
        end
      end
    end
  end
end
