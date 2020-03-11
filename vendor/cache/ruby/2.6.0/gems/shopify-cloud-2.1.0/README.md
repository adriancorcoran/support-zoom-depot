*ShopifyCloud Gem* :cloud:
==================================
[![Build status](https://badge.buildkite.com/4054ee65303c457c52e60942c803344ec909231da85c7539e8.svg)](https://buildkite.com/shopify/shopify-cloud?branch=master)


:cloud_with_rain:    The ShopifyCloud Gem is a Rails engine that aims to provide automatic pre-requirements configuration for your app to be deployed in Google Cloud.


Installation
========
In your `Gemfile` add:
```ruby
source 'https://packages.shopify.io/shopify/gems' do
  gem 'shopify-cloud', '~> 2'
end
```
Then run
```shell
bundle install
```

#### :bulb: Migrating from Shopify-cloud v1 to Shopify-cloud v2. Please read this small [guide](guides/migrate_to_v2.md)


Features and details
===============

When added to your project, the ShopifyCloud Gem will take care of configuring few things that you would have to do manually otherwise.

#### 🚅  Assets uploading on our CDN
At deploy time your assets get uploaded to our Google storage [bucket](https://console.cloud.google.com/storage/browser/cdn.shopifycloud.com/?project=shopify-tiers&organizationId=430199081660). A folder with the name of your app will be created containing all your assets.

The application's asset_host will be set to `cdn.shopify.com/shopifycloud/YOUR_APP_NAME`, which points at your app's folder in the GCS bucket and provides a global CDN for the application's assets instead of your app serving the assets from the application's domain.

In order for this feature to work, check if you have a `asset-uploading.yml.erb` template in your `config/deploy/production` directory.
If you do not, you can add it using the "Manage Runtime" feature on your app's profile in [ServicesDB](https://services.shopify.io/services).

If you don't want your assets to be uploaded to GCS and served from our CDN, you don't need the `asset-uploading.yml.erb` template.
You'll however have to let the shopify-cloud gem know that assets will be served locally.
```ruby
# config/environments/production.rb

config.shopify_cloud.disable_asset_host = true
```

Asset uploading comes with a set of sane defaults. However, if your application has specific needs, you can override some of these defaults (example staging).

```ruby
# config/environments/staging.rb

# Upload assets to a custom directory in the shared CDN.
# NOTE: This name should be unique to your application to avoid conflicting with others.
config.shopify_cloud.asset_uploader.directory = "my-app-staging"

# Change default caching
config.shopify_cloud.asset_uploader.cache_control = lambda do |asset|
  if /my_asset.js/ === asset.to_s
    "public, max-age=60"
  else
    "public"
  end
end
```

#### 🚅  Add a `/services/ping` routes used for uptime monitoring
The railtie appends a `services/ping` route to the list of your routes. The controller associated to that route will respond by a simple "pong". If you need something more complex, you can override this behaviour by adding this in your own `routes.rb` file and writing the logic you want in your controller.
```ruby
get 'services/ping', to: '<your_controller>#<your_action>'
```

#### 🚅  Configure the Rails logger to output Splunk formatted logs
ShopifyCloud will configure your logger to emits logs using the standard Rails log format in a threadsafe manner and writes log all at once allowing you to see all the logs that happen during the entire request cycle inside a single Splunk log section.

ShopifyCloud also make things easier for you to add extra logging on all your requests. If you need extra parameter logging, you can use
the `config.shopify_cloud.custom_logs` which accepts a Proc. The proc will be passed an `ActiveSupport::Event` object which contains a bunch
of [information](https://github.com/rails/rails/blob/c631e8d011a7cf3e7ade4e9e8db56d2b89bd530c/actionpack/lib/action_controller/metal/instrumentation.rb#L21-L27).
Your procs needs to return a hash containing all the parameters you want to log.
```ruby
# config/environments/production.rb

config.shopify_cloud.custom_logs = ->(event) do
  if event.method == 'GET'
    { elasticsearch_time: 'your_metric', 'identity_cache': 'cache_miss' ... }
  end
end
```

If you need something more custom, please read the [guide](guides/adding_extra_logging.md) we wrote on common logging usage.

How to find your logs:

* Example query: `kube_namespace="vpnify-production" sourcetype="rails:cloudplatform"`

#### 🚅  ShopifyMetrics

ShopifyCloud installs and enables [ShopifyMetrics](https://github.com/Shopify/shopify_metrics) (automatic instrumentation).

See [ShopifyMetrics readme](https://github.com/Shopify/shopify_metrics) for more details.

Pushing new release
======

Shopify cloud will deploy through a [shipit stack](https://shipit.shopify.io/shopify/shopify-cloud/production) to our package manager [package_cloud](https://packages.shopify.io/shopify/gems).
