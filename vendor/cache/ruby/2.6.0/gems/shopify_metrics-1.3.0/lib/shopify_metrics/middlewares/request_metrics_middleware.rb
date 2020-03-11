# frozen_string_literal: true
require "statsd-instrument"

module ShopifyMetrics
  module Middlewares
    class RequestMetrics
      REQUEST_START_HEADER = "HTTP_X_REQUEST_START"
      REQUEST_START_EDGE_HEADER = "HTTP_X_REQUEST_START_EDGE"
      REQUEST_QUEUING_CUT_OFF = Time.at(946_684_800).utc # any timestamps before this are thrown out (2000/1/1 UTC)
      # queue times less than a millisecond are meaningless due to VM clock drift
      REQUEST_QUEUING_TIME = "REQUEST_QUEUING_TIME"
      MIDDLEWARE_START = "HTTP_X_MIDDLEWARE_START"
      SERVER_TIMING_RESPONSE_HEADER = "Server-Timing"
      EDGE_LATENCY_TIME = "EDGE_LATENCY_TIME"
      REQUEST_TIME = "REQUEST_TIME"

      class << self
        attr_accessor :request_content_length_metric, :request_queuing_time_metric, :request_time_metric,
          :request_edge_latency_time_metric
      end
      @request_time_metric = "request_time"
      @request_queuing_time_metric = "request_queuing_time"
      @request_content_length_metric = "request_content_length"
      @request_edge_latency_time_metric = "edge_latency_time"

      def initialize(app)
        @app = app
      end

      def call(env)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        request_queuing_time = calculate_request_queuing_time(env[REQUEST_START_HEADER])
        env[REQUEST_QUEUING_TIME] = request_queuing_time if request_queuing_time

        edge_latency_time = nil
        if request_queuing_time
          edge_latency_time = calculate_request_queuing_time(env[REQUEST_START_EDGE_HEADER])
          if edge_latency_time
            edge_latency_time -= request_queuing_time
            env[EDGE_LATENCY_TIME] = edge_latency_time
          end
        end

        env[MIDDLEWARE_START] = "t=#{(Time.now.to_f * 1_000_000).to_i}"

        response = @app.call(env)

        response
      ensure
        begin
          if response
            tags = response_tags(env, response)
            end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            env[REQUEST_TIME] = ((end_time - start_time) * 1000).to_i

            if self.class.request_time_metric
              statsd(self.class.request_time_metric, env[REQUEST_TIME], tags)
            end

            if request_queuing_time && self.class.request_queuing_time_metric
              statsd(self.class.request_queuing_time_metric, request_queuing_time, tags)
            end

            if self.class.request_content_length_metric
              request = Rack::Request.new(env)
              statsd(self.class.request_content_length_metric, request.content_length, tags) if request.content_length
            end

            if edge_latency_time && self.class.request_edge_latency_time_metric
              statsd(self.class.request_edge_latency_time_metric, edge_latency_time, tags)
            end

            # Be defensive in an ensure block about what you accept.
            if response.respond_to?(:[]) && response[1].respond_to?(:[]=)
              add_headers(env, response[1])
            end
          else
            ShopifyMetrics.logger.error "[RequestMetrics] No response set"
          end
        rescue => e
          ShopifyMetrics.logger.error "[RequestMetrics] Error report request stats: #{e.message}"
        end
      end

      private

      def response_tags(env, response)
        tags = {}
        controller = env["action_controller.instance"]

        if controller
          tags[:controller] = controller.controller_path
          tags[:action] = controller.action_name
          tags[:request_method] = controller.request.method
          tags[:request_format] = controller.request.format.to_s
          controller_tags = controller.send(:shopify_metrics_tags)
          tags.merge!(controller_tags) if controller_tags
        end

        tags[:response_code] = response[0]

        # Publish the response type so it's easy to filter by certain
        # classes of response statuses. e.g. 301, 302, etc all become 3xx.
        tags[:response_type] = "#{response[0].to_s[0]}xx"

        ShopifyMetrics.add_application_tags(tags)
      end

      def statsd(metric_key, time, tags)
        StatsD.distribution(metric_key, time, tags: tags, sample_rate: 1.0)
      end

      def calculate_request_queuing_time(header_value)
        return nil unless header_value

        start_time = Time.now.utc
        parsed = parse_time_header(header_value)

        if parsed > REQUEST_QUEUING_CUT_OFF && parsed <= start_time
          ((start_time - parsed) * 1000).to_f
        else
          ShopifyMetrics.logger.warn("[RequestMetrics] Invalid or negative queue time:" \
            " parsed=#{parsed.to_f} > now=#{start_time.to_f}")
          nil
        end
      rescue => e
        ShopifyMetrics.logger.error "[RequestMetrics] Error parsing queuing timestamp: #{e.message}"
        nil
      end

      def parse_time_header(header_value)
        parsed_header = (header_value[/\d+\.\d+$/] || header_value[/\d+$/].to_f / 1000).to_f
        Time.at(parsed_header).utc
      end

      def add_headers(env, headers)
        server_timing_header = server_timing_header(env)
        headers[SERVER_TIMING_RESPONSE_HEADER] = server_timing_header
      end

      def server_timing_header(env)
        utilization = ShopifyMetrics::RaindropsMonitor.current_utilization
        data = +"processing;dur=#{env[REQUEST_TIME]}"
        data << ", socket_queue;dur=#{env[REQUEST_QUEUING_TIME].round(3)}" if env[REQUEST_QUEUING_TIME]
        data << ", edge;dur=#{env[EDGE_LATENCY_TIME].round(3)}" if env[EDGE_LATENCY_TIME]
        data << ", util;dur=#{utilization.round(3)}" if utilization
        data
      end
    end
  end
end
