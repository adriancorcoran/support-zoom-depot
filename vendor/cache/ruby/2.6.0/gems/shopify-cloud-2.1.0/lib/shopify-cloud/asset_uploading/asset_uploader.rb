# frozen_string_literal: true

require 'active_support/core_ext/benchmark'
require 'google/cloud/storage'
Google::Apis.logger = ActiveSupport::Logger.new(STDOUT)
Google::Apis.logger.level = Logger::INFO

module ShopifyCloud
  class AssetUploader
    APPLICATION_NAME = Rails.application.class.parent_name.underscore
    BUCKET = 'cdn.shopifycloud.com'
    PROJECT = 'shopify-tiers'
    MAXIMUM_BACKOFF_TIME = 32
    MAXIMUM_RETRY_NUMBER = 5

    attr_reader :manifests, :bucket

    def self.default_bucket
      Google::Cloud::Storage.new(project: PROJECT).bucket(BUCKET)
    end
    delegate :default_bucket, to: :class

    def self.asset_directory
      Rails.application.config.shopify_cloud.asset_uploader.directory || APPLICATION_NAME
    end
    delegate :asset_directory, to: :class

    def initialize(bucket = default_bucket, manifests = nil)
      @manifests = if manifests
        Array(manifests)
      elsif Rails.application.respond_to?(:assets_manifest)
        [Rails.application.assets_manifest, SewingKitManifest.new, WebpackerManifest.new]
      else
        [SewingKitManifest.new, WebpackerManifest.new]
      end

      @bucket = bucket
      @options = {
        tags: {
          container: Socket.gethostname,
          app: "#{APPLICATION_NAME}.#{Rails.env}",
          bucket: "#{PROJECT}/#{BUCKET}",
        },
        no_prefix: true,
      }
    end

    def run
      Google::Apis.logger.info("Locating all assets")
      assets_count = 0

      queue = manifests.each_with_object(Queue.new) do |manifest, object|
        assets_count += manifest.assets.length

        manifest.assets.each_value do |asset_name|
          asset_path = File.join(manifest.dir, asset_name)
          asset_path += '.gz' if gzip_exists?(asset_path)
          object << asset_path
        end
      end

      Google::Apis.logger.info("Found #{assets_count} assets")
      Google::Apis.logger.info("Starting asset upload to #{BUCKET}")

      statsd_time do
        consume_in_parallel(queue) do |asset|
          upload(Pathname.new(asset))
        end
      end
      Google::Apis.logger.info("Assets uploaded successfully")
    end

    private

    def statsd_time
      duration_ms = Benchmark.ms { yield }
      StatsD.measure('shopifycloud.assets.upload_duration', duration_ms, @options)
    end

    def gzip_exists?(asset)
      File.exist?("#{asset}.gz")
    end

    def upload(asset)
      StatsD.increment('shopifycloud.assets.upload_count', @options)
      bucket.upload_file(asset.to_s, cloudplatform_path(asset), asset_options(asset))
    rescue Google::Cloud::Error, Google::Apis::ServerError => e
      Thread.current['retry_number'] += 1
      Google::Apis.logger.info("Failed to upload assets with error message: #{e.message}")
      if Thread.current['retry_number'] <= MAXIMUM_RETRY_NUMBER
        Google::Apis.logger.info("Retrying to upload assets")
        StatsD.increment('shopifycloud.assets.upload_retries', @options)
        sleep([backoff_time(Thread.current['retry_number']), MAXIMUM_BACKOFF_TIME].min)
        retry
      else
        Google::Apis.logger.info("Unable to upload assets after exponential backoff")
        StatsD.increment('shopifycloud.assets.upload_errors', @options)
        raise e
      end
    end

    def cloudplatform_path(asset)
      app_public_asset_path = Rails.root.join('public')
      asset_relative_path = asset.relative_path_from(app_public_asset_path).to_s.gsub(/\.gz\Z/, '')

      "#{asset_directory}/#{asset_relative_path}"
    end

    def cache_control_for_asset(asset)
      cache_control = Rails.application.config.shopify_cloud.asset_uploader.cache_control
      if cache_control.respond_to?(:call)
        cache_control.call(asset)
      else
        cache_control
      end
    end

    def asset_options(asset)
      {
        cache_control: cache_control_for_asset(asset),
        acl: 'public_read',
        content_disposition: 'inline',
        content_type: Mime::Type.lookup_by_extension(content_type(asset)).to_s,
      }.tap do |options|
        options[:content_encoding] = 'gzip' if asset.extname == '.gz'
      end
    end

    def content_type(asset)
      if asset.extname == '.gz'
        asset.to_s.split('.').second_to_last
      else
        asset.to_s.split('.').last
      end
    end

    def backoff_time(retry_number)
      # Check https://cloud.google.com/storage/docs/exponential-backoff for more inforamtion about this method.
      (2**(retry_number - 1)) + (rand(1000) / 1000.0)
    end

    def consume_in_parallel(assets)
      error = nil
      threads = Array.new(10) do
        Thread.new do
          StatsD.increment('shopifycloud.assets.upload_threads', @options)
          until assets.empty?
            begin
              Thread.current['retry_number'] = 0 if Thread.current['retry_number'].nil?
              yield assets.pop
            rescue => e
              error = e
            end
          end
        end
      end
      threads.each(&:join)

      raise error if error
    end
  end
end
