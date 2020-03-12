# frozen_string_literal: true
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @user2 = users(:two)
    @new_user = {
      name: 'tom',
      password: 'secret',
    }
  end

  def create_user
    visit(users_url)
    click_on("Add User")
    fill_in_user(@new_user)
    click_on("Add User")
  end

  def fill_in_user(user)
    fill_in("User Name", with: user[:name])
    fill_in("Password", with: user[:password])
    fill_in("Confirm", with: user[:password])
  end

  test "visiting the index" do
    login_as(@user)
    visit users_url
    assert_selector "h1", text: "Users"
  end

  test "creating a user" do
    login_as(@user)
    current_num_users = User.all.size
    create_user
    assert_text "User #{@new_user[:name]} was successfully created"
    assert_equal current_num_users + 1, User.all.size
  end

  test "cannot create a user without data" do
    current_num_users = User.all.size
    login_as(@user)
    visit(users_url)
    click_on("Add User")
    click_on("Add User")
    assert_text "Name can't be blank"
    assert_equal current_num_users, User.all.size
  end

  test "cannot create a user with mismatching passwords" do
    current_num_users = User.all.size
    login_as(@user)
    visit(users_url)
    click_on("Add User")
    fill_in_user(@new_user)
    fill_in("Confirm", with: 'oops')
    click_on("Add User")
    assert_text "Password confirmation doesn't match Password"
    assert_equal current_num_users, User.all.size
  end

  test "updating a user" do
    login_as(@user)
    new_name = @user.name + ' ' + @user.name
    visit users_url
    first('a.link-edit').click
    fill_in "User Name", with: new_name
    click_on "Update User"
    assert_text "User #{new_name} was successfully updated"
  end

  test "error editing a user with blank field" do
    login_as(@user)
    visit(users_url)
    first('a.link-edit').click
    fill_in "User Name", with: ''
    click_on "Update User"
    assert_text "Name can't be blank"
  end

  test "error editing a user with mismatched passwords" do
    login_as(@user)
    visit(users_url)
    first('a.link-edit').click
    fill_in "Password", with: 'oops'
    fill_in "Confirm", with: 'oops1'
    click_on "Update User"
    assert_text "Password confirmation doesn't match Password"
  end

  test "delete a user" do
    login_as(@user2)
    visit users_url
    page.accept_confirm do
      first('a.link-delete').click
    end
    assert_text "User was successfully removed"
  end

  test "cannot delete last user" do
    User.destroy_by(name: @user2.name)
    assert 1, User.all.size
    login_as(@user)
    visit users_url
    page.accept_confirm do
      first('a.link-delete').click
    end
    assert_text "Can't delete last user!"
    assert 1, User.all.size
  end
end
