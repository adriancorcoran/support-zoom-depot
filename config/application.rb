# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SupportZoomDepot
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(6.0)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # don't log sensitive info
    config.filter_parameters += [:credit_card_number, :expiration_date, :routing_number, :account_number, :po_number]

    config.i18n.available_locales = [:en, :ga]
    config.i18n.default_locale = :en
  end
end
