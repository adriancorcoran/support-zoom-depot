# frozen_string_literal: true

namespace :cloudplatform do
  desc 'Upload assets to CDN'
  task upload_assets: :environment do
    ShopifyCloud::AssetUploader.new.run
  end
end
