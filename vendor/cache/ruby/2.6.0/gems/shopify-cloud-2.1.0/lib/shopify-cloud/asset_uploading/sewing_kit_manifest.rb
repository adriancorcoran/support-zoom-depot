# frozen_string_literal: true

module ShopifyCloud
  class SewingKitManifest
    def assets
      return {} unless defined?(SewingKit)

      manifest.each_with_object({}) do |(k, v), hash|
        v.each do |ext, path|
          hash["#{k}_#{ext}"] = path
        end
      end
    end

    def dir
      Rails.root.join('public')
    end

    private

    def manifest
      if SewingKit::Webpack::Manifest.respond_to?(:manifest)
        SewingKit::Webpack::Manifest.manifest
      else
        JSON.parse(File.read(manifest_path))
      end
    end

    def manifest_path
      raise 'Only sewing_kit@0.4.x supports manfiest_path' unless defined?(SewingKit) && SewingKit::VERSION =~ /^0\.4\./

      sewing_kit_config = Rails.application.config.sewing_kit.webpack
      Rails.root.join(sewing_kit_config.manifest_dir, sewing_kit_config.manifest_filename)
    end
  end
end
