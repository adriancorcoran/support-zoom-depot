# frozen_string_literal: true

module ShopifyCloud
  class WebpackerManifest
    def assets
      if defined?(::Webpacker)
        Webpacker.manifest.refresh.except("entrypoints")
      else
        {}
      end
    end

    def dir
      Webpacker.config.public_path.to_s
    end
  end
end
