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

module AuthenticationHelper
  def login_as(user)
    if respond_to?(:visit)
      login_with_visit(user)
    else
      post(login_url, params: { name: user.name, password: 'secret' })
    end
  end

  def logout
    delete(logout_url)
  end

  def setup
    login_as(users(:one))
  end

  private

  def login_with_visit(user)
    visit(login_url)
    fill_in(:name, with: user.name)
    fill_in(:password, with: 'secret')
    click_on('Login')
  end
end

module ActionDispatch
  class IntegrationTest
    include AuthenticationHelper
  end
end

module ActionDispatch
  class SystemTestCase
    include AuthenticationHelper
  end
end
