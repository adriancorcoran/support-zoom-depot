# frozen_string_literal: true
require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  setup do
    @product = products(:one)
    @user = users(:one)
    @new_product = products(:ruby)
    @new_product.title = 'AAAA First Product Title'
  end

  def login
    visit(logout_url)
    visit(login_url)
    fill_in('name', with: @user[:name])
    fill_in('password', with: 'secret')
    click_on("Login")
  end

  def create_product
    visit(products_url)
    click_on("New Product")
    fill_in("Title", with: @new_product.title)
    fill_in("Description", with: @new_product.description)
    fill_in("Image Url", with: @new_product.image_url)
    fill_in("Price", with: @new_product.price)
    click_on("Add Product")
  end

  test "visiting the products page" do
    login
    visit products_url
    assert_selector "h1", text: "Products"
  end

  test "creating a Product" do
    current_num_products = Product.all.size
    login
    create_product
    assert_text "Product was successfully created"
    assert_equal current_num_products + 1, Product.all.size
  end

  test "cannot create a Product" do
    current_num_products = Product.all.size
    login
    visit(products_url)
    click_on("New Product")
    click_on("Add Product")
    assert_text "Title can't be blank"
    assert_equal current_num_products, Product.all.size
  end

  test "updating a Product" do
    login
    visit products_url
    click_on "Edit", match: :first
    fill_in "Title", with: @product.title + ' ' + @product.title
    click_on "Update Product"

    assert_text "Product was successfully updated"
  end

  test "cannot edit a Product" do
    login
    visit products_url
    click_on "Edit", match: :first
    fill_in "Title", with: ''
    click_on "Update Product"

    assert_text "Title can't be blank"
  end

  test "destroying a Product" do
    login
    create_product
    visit products_url
    page.accept_confirm do
      click_on "Delete", match: :first
    end

    assert_text "Product was successfully deleted"
  end

  test "cannot destroy a Product" do
    login
    visit products_url
    page.accept_confirm do
      click_on "Delete", match: :first
    end

    assert_text "Product could not be deleted, it is present in a cart or order!"
  end

  test "viewing product ordered in" do
    login
    visit products_url
    click_on "Who Bought?", match: :first
    assert_text "Customers who bought"
  end
end
