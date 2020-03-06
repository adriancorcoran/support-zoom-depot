# frozen_string_literal: true
require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should prompt for login" do
    get login_url
    assert_response :success
  end

  test "should login successfully" do
    user = users(:one)
    post login_url, params: { name: user.name, password: 'secret' }
    assert_redirected_to admin_url
    assert_equal user.id, session[:user_id]
  end

  test "should fail login" do
    user = users(:one)
    post login_url, params: { name: user.name, password: 'wrong' }
    assert_redirected_to login_url
  end

  test "should logout by delete" do
    delete logout_url
    assert_redirected_to login_url
  end

  test "should logout by get" do
    get logout_url
    assert_redirected_to login_url
  end
end
