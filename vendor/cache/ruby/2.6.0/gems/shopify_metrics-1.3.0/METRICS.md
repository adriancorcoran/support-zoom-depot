# Performance Metrics

## HTTP Requests

### Standard tags

- `action`
- `controller`
- `request_format`
- `request_method`
- `response_code`
- `response_type`

### In app request time

Time to complete a request, from the application perspective.

- StatsD metric name: `request_time`
- StatsD metric type: distribution

#### Produced by

- `ShopifyMetrics::Middlewares::RequestMetrics`

### Request queuing time

Time before a request actually start being processed.

- Statsd metric name: `request_queuing_time`
- StatsD metric type: distribution

This metric is emitted when the application start processing a request.
It relies on the presence of a header `X-Request-Start` set by the first HTTP
hop.

#### Produced by

- `ShopifyMetrics::Middlewares::RequestMetrics`

### In app request content-type length

Size of the HTTP response body.

- Statsd metric name: `request_content_length`
- StatsD metric type: distribution

This metric is based on the response header `Content-Length`.
Some responses don't provide this header (chunked encoding), in this case,
this metric is not emitted.

#### Produced by

- `ShopifyMetrics::Middlewares::RequestMetrics`

## Puma

### Desired workers

Amount of worker processes configured.

- StatsD metric name: `puma_desired_workers`
- StatsD metric type: gauge

### Booted workers

Amount of workers ready to serve requests.

- StatsD metric name: `puma_booted_workers`
- StatsD metric type: gauge

### Running

Total of threads running inside a worker. Will be between the minimum and
maximum thread count configured.

- StatsD metric name: `puma_running`
- StatsD metric type: gauge

### Backlog

Total of requests queued up inside a worker.

- StatsD metric name: `puma_backlog`
- StatsD metric type: gauge

### Pool capacity

Total of idle threads not serving requests inside a worker. Under full load
this should be 0, otherwise might indicate too much threads configured.

- StatsD metric name: `puma_pool_capacity`
- StatsD metric type: gauge

### Max threads

Maximum of threads configured for a worker.

- StatsD metric name: `puma_max_threads`
- StatsD metric type: gauge

#### Produced by:

- `puma/plugin/shopify_metrics`

## Sidekiq

### Standard tags

 - `job_name`
 - `job_queue`
 - `job_error`

### Sidekiq queued time

Time taken to work off a job on the queue, from the application perspective.

- StatsD metric name: `sidekiq_queued_time`
- StatsD metric type: distribution

#### Tags

 - `job_error` - Included when the enqueue raises an error

#### Produced by

- `ShopifyMetrics::Middlewares::SidekiqMetrics`

### Sidekiq perform time

Time taken to perform a job, from the application perspective.

- StatsD metric name: `sidekiq_perform_time`
- StatsD metric type: distribution

#### Tags

 - `job_error` - Included when the perform raises an error

#### Produced by:

- `ShopifyMetrics::Middlewares::SidekiqMetrics`

## Sidekiq Performance Metrics Job
All the following metrics are produced by using the [`Sidekiq::Stats` API](https://github.com/mperham/sidekiq/wiki/API#stats).

These metrics have no standard tags.

### Produced by:

- `ShopifyMetrics::Jobs::SidekiqPerformanceMetrics`

### Sidekiq DeadSet size

- StatsD metric name: `sidekiq_dead`
- StatsD metric type: gauge

### Sidekiq RetrySet size

- StatsD metric name: `sidekiq_retry`
- StatsD metric type: gauge

### Number of enqueued jobs

- StatsD metric name: `sidekiq_enqueued`
- StatsD metric type: gauge

### Number of processes

- StatsD metric name: `sidekiq_processes`
- StatsD metric type: gauge

### Number of workers

- StatsD metric name: `sidekiq_workers`
- StatsD metric type: gauge

### Number of scheduled jobs

- StatsD metric name: `sidekiq_scheduled`
- StatsD metric type: gauge

### Number of processed jobs

- StatsD metric name: `sidekiq_processed`
- StatsD metric type: gauge

### Number of failed jobs

- StatsD metric name: `sidekiq_failed`
- StatsD metric type: gauge

### Queue size

- StatsD metric name: `sidekiq_queue_size`
- StatsD metric type: gauge

#### Tags

 - `job_queue`: allows counting by queue.
