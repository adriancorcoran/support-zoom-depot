# frozen_string_literal: true

require 'statsd-instrument'
require 'raindrops'

module ShopifyMetrics
  module RaindropsMonitor
    extend self

    EXTERNAL_ENCODING = Encoding.default_external

    attr_accessor :total_workers, :stats_file_path, :stats_file_ttl, :update_stats_interval

    @stats_file_path = '/tmp/raindrops_stats'
    @stats_file_ttl = 1
    @update_stats_interval = 0.1
    @total_workers = (ENV['UNICORN_WORKERS'] || ENV['PUMA_WORKERS']).to_i

    # The monitor thread runs in the master process so we can't easily share
    # memory.  Using files, we can allow all unicorn worker processes to access
    # the current utilization stats without the overhead of a slow Netlink call
    # per request.
    def current_utilization
      active, queued, updated_at = read_stats_from_file
      return unless active && queued && updated_at
      return if (Process.clock_gettime(Process::CLOCK_MONOTONIC, :second) - updated_at) >= @stats_file_ttl

      calculate_utilization(active, queued)
    end

    def init(interval: @update_stats_interval)
      return unless Raindrops::Linux.respond_to?(:tcp_listener_stats) && ENV['PORT']
      return if @raindrops_thread&.alive?

      spawn_raindrops_thread(interval)
    end

    # This is useful to check from the Workers whether the thread is running
    # somewhere else.
    def running?
      File.exist?(@stats_file_path)
    rescue StandardError
      nil
    end

    def capture_metrics(dump_to_file: false)
      return unless Raindrops::Linux.respond_to?(:tcp_listener_stats) && ENV['PORT']

      tags = {
        'container-id' => Socket.gethostname.to_s,
        'port' => ENV["PORT"],
      }
      tags = ShopifyMetrics.add_application_tags(tags)

      begin
        stats = Raindrops::Linux.tcp_listener_stats(addr)[addr]

        write_stats_to_file(stats) if dump_to_file

        StatsD.gauge('raindrops.active', stats.active, tags: tags)
        StatsD.gauge('raindrops.queued', stats.queued, tags: tags)

        utilization = calculate_utilization(stats.active, stats.queued)
        StatsD.distribution('raindrops.utilization', utilization, tags: tags) if utilization
      rescue RuntimeError
        # Raindrops::Linux.tcp_listener_stats can raise a NLMSG_ERROR. We catch it since there
        # is nothing else to do.
        nil
      end
    end

    private

    def addr
      -"0.0.0.0:#{ENV['PORT']}"
    end

    def spawn_raindrops_thread(interval)
      @raindrops_thread = Thread.new do
        loop do
          capture_metrics(dump_to_file: true)
          sleep(interval)
        end
      end
    end

    def calculate_utilization(active, queued)
      unless total_workers
        ShopifyMetrics.logger.error(<<~EOE)
          "[#{name}] Unable to get the number of workers to properly report the
          `raindrops.utilization` metric. By default, this is set to
          `UNICORN_WORKERS` or `PUMA_WORKERS`. Please either set these or use
          `RaindropsMonitor.total_workers = integer` in your `before_fork`.
        EOE

        return
      end

      # This gives a ratio of how utilized a web container is. For example, with
      # a total of 16 workers, a utilization value of 1.5 (150%) means that we
      # have 16 active and 8 queued requests/sockets
      (active + queued).to_f / total_workers
    end

    def write_stats_to_file(stats)
      marshaled_stats = Marshal.dump([
        stats.active,
        stats.queued,
        Process.clock_gettime(Process::CLOCK_MONOTONIC, :second),
      ])

      tempfilename = File.join(Dir.tmpdir, "raindrop_monitor_#{Process.pid}")
      tempfile = File.open(tempfilename, 'w', encoding: marshaled_stats.encoding)
      begin
        tempfile.write(marshaled_stats)
      ensure
        tempfile.close
        File.rename(tempfile.path, @stats_file_path)
      end
    end

    def read_stats_from_file
      Marshal.load(File.read(@stats_file_path))
    rescue StandardError # doesn't exist or invalid marshal
      nil
    end
  end
end
