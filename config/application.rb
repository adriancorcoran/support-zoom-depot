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

    # pass translations to js
    config.middleware.use(I18n::JS::Middleware)

    # add all .yml files to translation array
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]
    # set default translation
    config.i18n.default_locale = :en
  end
end
