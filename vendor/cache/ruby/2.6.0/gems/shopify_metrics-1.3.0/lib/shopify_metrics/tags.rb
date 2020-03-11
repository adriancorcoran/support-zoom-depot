# frozen_string_literal: true
module ShopifyMetrics
  module Tags
    # Modifies and returns the argument adding application specifig tags
    def add_application_tags(tags)
      if defined?(Rails)
        tags.merge!(Rails.application.config.x.shopify_metrics_tags)
        tags['environment'] = Rails.env.to_s
      end
      tags
    end

    # Returns the hash of application tags keys and values
    def application_tags
      add_application_tags({})
    end
  end
end
