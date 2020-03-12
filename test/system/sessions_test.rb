# frozen_string_literal: true
require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    @user = users(:one)
  end

  def login
    visit(logout_url)
    visit(login_url)
    fill_in('name', with: @user[:name])
    fill_in('password', with: 'secret')
    click_on("Login")
  end

  test "can't visit manage products" do
    visit logout_url
    visit products_url
    assert_selector "h1", text: "Login"
  end

  test "can't visit manage orders" do
    visit logout_url
    visit orders_url
    assert_selector "h1", text: "Login"
  end

  test "can't visit manage users" do
    visit logout_url
    visit users_url
    assert_selector "h1", text: "Login"
  end

  test "can visit manage products" do
    login
    visit products_url
    assert_selector "h1", text: "Products"
  end

  test "can visit manage users" do
    login
    visit users_url
    assert_selector "h1", text: "Users"
  end
end
