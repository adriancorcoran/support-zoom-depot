# frozen_string_literal: true
module ShopifyMetrics
  module ActionControllerTags
    private

    # Override this method in a controller to add tags to the metrics sent by the RequestMetrics middleware.
    #
    # It's defined as private as not to be considered a controller action.
    def shopify_metrics_tags
    end
  end
end
