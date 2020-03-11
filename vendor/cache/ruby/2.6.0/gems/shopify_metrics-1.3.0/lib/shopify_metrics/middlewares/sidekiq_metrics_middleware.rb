# frozen_string_literal: true
require "statsd-instrument"

module ShopifyMetrics
  module Middlewares
    class SidekiqMetrics
      def call(_worker, job, _queue, _redis = nil)
        # We add the queue and the job type so that we can monitor
        # individual jobs and queues in Datadog if necessary.
        tags = {
          job_queue: job.fetch('queue', nil) || 'unknown',
          # ActiveJob class names are reported under the "wrapped" key,
          # while bare Sidekiq Workers show up under the "class" key.
          job_name: (job.fetch('wrapped', job.fetch('class', nil)) || 'unknown').underscore,
          job_error: nil,
        }

        ShopifyMetrics.add_application_tags(tags)

        result = nil
        exception = nil

        StatsD.distribution('sidekiq_queued_time', milliseconds_since_enqueued(job), tags: tags)

        StatsD.distribution('sidekiq_perform_time', tags: tags) do
          begin
            result = yield
          rescue => exception
            # We also add the job error that occurred.
            tags[:job_error] = exception.class.to_s.underscore
          end
        end

        raise exception if exception

        result
      end

      private

      def milliseconds_since_enqueued(job)
        enqueued = job.fetch('enqueued_at', nil)
        return 0 unless enqueued
        (Time.current.utc - Time.at(enqueued).utc) * 1000
      end
    end
  end
end
