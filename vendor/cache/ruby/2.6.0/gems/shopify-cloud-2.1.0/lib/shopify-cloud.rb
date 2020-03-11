# frozen_string_literal: true

require 'shopify-cloud/engine'
require 'shopify-cloud/log_subscriber'
require 'statsd-instrument'
require 'shopify_metrics'
require 'buffered_logger'

module ShopifyCloud
  autoload :AssetUploader,                  'shopify-cloud/asset_uploading/asset_uploader'
  autoload :SewingKitManifest,              'shopify-cloud/asset_uploading/sewing_kit_manifest'
  autoload :WebpackerManifest,              'shopify-cloud/asset_uploading/webpacker_manifest'
  autoload :ShopifyControllerLogSubscriber, 'shopify-cloud/shopify_controller_log_subscriber'
  autoload :Status,                         'shopify-cloud/status'
  autoload :ActiveJobBufferedLogging,       'shopify-cloud/active_job_buffered_logging'
end
