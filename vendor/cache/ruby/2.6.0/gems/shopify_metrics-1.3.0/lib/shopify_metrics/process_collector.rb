# frozen_string_literal: true

module ShopifyMetrics
  class ProcessCollector
    INTERVAL = 30
    RSS_KEY = 'rss'
    THREAD_COUNT_KEY = 'threads_count'
    OBJECTS_ALLOCATED_KEY = 'allocated_objects_count'
    PID_KEY = 'pid'
    TYPE_KEY = 'type'
    DEFAULT_TYPE = 'ruby'

    class << self
      def init(interval: INTERVAL, type: DEFAULT_TYPE)
        spawn_monitor_thread(interval, type)
      end

      def collect(type)
        ShopifyMetrics.logger.info do
          info = +"[#{name}]"

          tags.each do |key, value|
            info << " #{key}=\"#{value}\""
          end

          info << " #{TYPE_KEY}=\"#{type}\""
          info << " #{RSS_KEY}=\"#{rss}\""
          info << " #{THREAD_COUNT_KEY}=\"#{Thread.list.size}\""
          stat = GC.stat
          info << " #{OBJECTS_ALLOCATED_KEY}=\"#{stat[:total_allocated_objects]}\""
          info
        end
      end

      private

      def spawn_monitor_thread(interval, type)
        return if @thread&.alive?

        @thread = Thread.new do
          loop do
            begin
              collect(type)
            rescue => e
              ShopifyMetrics.logger.error do
                "[#{name}] Error encountered while collecting process metrics: #{e}"
              end
            ensure
              sleep(interval)
            end
          end
        end
      end

      def tags
        @tags ||= ShopifyMetrics.add_application_tags(
          'container_id' => Socket.gethostname.to_s,
          PID_KEY => Process.pid,
        )
      end

      def rss
        @pagesize ||=
          begin
            %x{getconf PAGESIZE}.to_i
          rescue
            4096
          end

        begin
          File.read("/proc/self/statm").split(' ')[1].to_i * @pagesize
        rescue
          0
        end
      end
    end
  end
end
