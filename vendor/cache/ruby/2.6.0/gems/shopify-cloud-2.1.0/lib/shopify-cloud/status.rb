# frozen_string_literal: true

module ShopifyCloud
  module Status
    extend self

    def to_h
      {
        'location' => location,
        'state' => state,
      }
    end

    def location
      env('LOCATION')
    end

    def state
      env('STATE').inquiry
    end

    delegate :maintenance?, :active?, :standby?, to: :state

    private

    def env(var)
      ENV.fetch(var, 'unknown')
    end
  end
end
