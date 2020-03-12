# frozen_string_literal: true
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    def setup
      login_as(users(:one))
    end

    def login_as(user)
      post(login_url, params: { name: user.name, password: 'secret' })
    end

    def logout
      delete(logout_url)
    end
  end
end

module ActionDispatch
  class SystemTestCase
    def login_as(user)
      visit(login_url)
      fill_in(:name, with: user.name)
      fill_in(:password, with: 'secret')
      click_on('Login')
    end

    def logout
      visit(logout_url)
    end
  end
end
