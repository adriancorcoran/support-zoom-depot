# frozen_string_literal: true

module ShopifyCloud
  module ActiveJobBufferedLogging
    def self.included(base)
      base.around_perform(prepend: true) do |_, block|
        if Rails.logger.started?
          block.call
        else
          Rails.logger.start(&block)
        end
      end
    end
  end
end
