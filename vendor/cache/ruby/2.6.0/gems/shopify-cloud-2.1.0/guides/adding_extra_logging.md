#### Common use case: Adding extra logging on each request :bulb:

To make your life easier and debugging simpler, a common use case is to add extra logging on all your requests.
Depending on your needs you'll need to implement different solutions. Here are the top three implementations that you might need.
First, let's have a look at what the default log from Rails will look like after creating a project from scratch.

```log
[ABCDEF-123456] Started GET "/?test=param" for 127.0.0.1 at 2004-11-23 20:04:44 +0000
[ABCDEF-123456] Processing by ApplicationController#main as HTML
[ABCDEF-123456]   Parameters: {"params":{"test":"param"}}
[ABCDEF-123456]   Rendering text template
[ABCDEF-123456]   Rendered text template (0.0ms)
[ABCDEF-123456] Completed 200 OK in 0ms (Views: 0.0ms)
```

---------------------------------

#### Rails "Log Tags"

Before each line of log you can notice that it is prefixed with `[ABCDEF-123456]` which is the Request ID.
In Rails, a "tag" is a section surrounded by brackets which gets added before any line of log.
The Request ID "tag", gets prepended on each log because of a configuration inside your application called "log_tags", here is an [example](https://github.com/Shopify/solid_track/blob/294614aa3b83c12d3b32cf94ca7831a5653a2319/config/environments/production.rb#L42).

You can if you desire add extra tags which will get prepended before each log by simply filling the `log_tags` configuration array with `Symbols` that represents method present on the `Request` object.

For instance, if you wanted to add as tag the IP of the request:
<details>
  <summary> Example Symbol </summary>

  ```ruby
  config.log_tags = [:ip]
  ```

  And the resulting log will look like this
  ```log
  [127.0.0.1] Started GET "/?test=param" for 127.0.0.1 at 2004-11-23 20:04:44 +0000
  ```
</details>

You can also pass a Proc inside `log_tags` array, your Proc will get passed an `ActionDispatch::Request` object.

<details>
  <summary> Example with Proc </summary>

  ```ruby
  my_proc = ->(request) do
    'Hello World!'
  end
  config.log_tags = [my_proc]
  ```

  And the resulting log will look like this
  ```log
  [Hello World!] Started GET "/?test=param" for 127.0.0.1 at 2004-11-23 20:04:44 +0000
  ```
</details>

:+1: Display various information coming from the request.
:-1: Display metrics (In example how long it took for ElasticSearch). Because the log get displayed before the response is sent to the client.

-----------------------------

#### Shopify-Cloud "Custom logs"


Another common use case is to log metrics for each requests. For the metric to be accurate you need to wait until the response is sent to the client.
While you can achieve this with Rails, we tried to make it extra simpler and added a feature in Shopify-Cloud called `custom_logs`.

Custom Logs, are logs that will be output **after** the reponse is sent back to the client.

Here is how you can configure it.

<details>
  <summary> Configure ShopifyCloud custom_logs </summary>

  ```ruby
  config.shopify_cloud.custom_logs = ->(event) do
    { elasticsearch_time: ElasticSearch.time_spent }
  end
  ```

  And the resulting result will look like this
  ```log
   [ABCDEF-123456] Started GET "/?test=param" for 127.0.0.1 at 2004-11-23 20:04:44 +0000
   [ABCDEF-123456] Processing by ApplicationController#main as HTML
   [ABCDEF-123456]   Parameters: {"params":{"test":"param"}}
   [ABCDEF-123456]   Rendering text template
   [ABCDEF-123456]   Rendered text template (0.0ms)
>> [ABCDEF-123456]   Request Information: {"elasticsearch_time":"1.5ms"}
   [ABCDEF-123456] Completed 200 OK in 0ms (Views: 0.0ms)
  ```

  The `custom_logs` proc once called will get passed an `ActiveSupport::Event` object which contains
  information about the request, as well as the response.
  The Proc needs to return a Hash containing the metrics you'd like to output.
</details>

:+1: Simple to setup, will fit most use case to display any metrics.
:-1: You can't format the way the line of log looks like.

-------------------------

#### Implement your own Subscriber

If the two solutions above don't suit your needs and you need something specific for your application, Rails has a way to help you.
Let's have a look at what kind of log you **can't** get with the two solutions above.

```log
  [ABCDEF-123456] Started GET "/?test=param" for 127.0.0.1 at 2004-11-23 20:04:44 +0000
> [ABCDEF-123456] New incoming request. Will be dispatched to canary since header include the 'X-Canary' directive.
  [ABCDEF-123456] Processing by ApplicationController#main as HTML
  [ABCDEF-123456]   Parameters: {"params":{"test":"param"}}
  [ABCDEF-123456]   Rendering text template
  [ABCDEF-123456]   Rendered text template (0.0ms)
> [ABCDEF-123456] Finished serving request. Created new cookie shopify_visitor_name with value "Edouard"
  [ABCDEF-123456] Completed 200 OK in 0ms (Views: 0.0ms)
```


As you can see this type of logs are very custom and Shopify-Cloud can't implement all use cases, it will be your responsability.
Without going too much into the details, here is a way to achieve this.

<details>
  <summary> Implement your own Subscriber </summary>

  ```ruby
  class RequestLogSubscriber < ActiveSupport::Subscriber
    attach_to(:action_controller)

    def start_processing(event)
      payload = event.payload

      return unless payload[:headers]['Canary']
      Rails.logger.info('New incoming request. Will be dispatched to canary since header include the 'X-Canary' directive.')
    end

    def process_action(event)
      payload = event.payload

      return unless payload[:shopify_visitor_cookie]
      Rails.logger.info(
        'Finished serving request. Created new cookie shopify_visitor_name with value "#{payload[:shopify_visitor_cookie]}"'
      )
    end
  end

  class ApplicationController < ActionController::Base
    private

    def append_into_to_payload(payload)
      return unless response.cookies[:shopify_visitor_cookie]

      payload[:shopify_visitor_cookie] = response.cookies[:shopify_visitor_cookie]
    end
  end
  ```
</details>
