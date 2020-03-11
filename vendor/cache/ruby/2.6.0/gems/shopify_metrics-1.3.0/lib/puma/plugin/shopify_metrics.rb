# frozen_string_literal: true

require "json"
require "puma/plugin"
require "shopify_metrics/puma_stats"

Puma::Plugin.create do
  def start(_launcher)
    in_background do
      loop do
        begin
          stats = ::ShopifyMetrics::PumaStats.new(fetch_stats)

          master_tags = tags_for("master")
          StatsD.gauge("puma_desired_workers", stats.desired_workers, tags: master_tags)
          StatsD.gauge("puma_booted_workers", stats.booted_workers, tags: master_tags)

          stats.workers.each do |worker|
            worker_tags = tags_for(worker.name)
            StatsD.gauge("puma_running", worker.running, tags: worker_tags)
            StatsD.gauge("puma_backlog", worker.backlog, tags: worker_tags)
            StatsD.gauge("puma_pool_capacity", worker.pool_capacity, tags: worker_tags)
            StatsD.gauge("puma_max_threads", worker.max_threads, tags: worker_tags)
          end

          sleep 1
        rescue => e
          ShopifyMetrics.logger.error(<<~ERROR_MSG)
            [ShopifyMetrics] Error encountered while collecting Puma metrics:
            #{e.class}: #{e}
          ERROR_MSG
        end
      end
    end
  end

  def fetch_stats
    stats = Puma.stats
    if stats.is_a?(String)
      JSON.parse(stats, symbolize_names: true)
    else
      stats
    end
  end

  def tags_for(worker_name)
    tags = {
      'worker' => worker_name,
      'container-id' => Socket.gethostname.to_s,
    }
    ShopifyMetrics.add_application_tags(tags)
  end
end
