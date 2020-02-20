require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  def new_product(image_url)
    Product.new(title: "My Books Title", description: "My Book's Description", price: 1, image_url: image_url)
  end

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:image_url].any?
    assert product.errors[:price].any?
  end
  
  test "product price must be positive" do
    product = new_product("my_image.jpg")
    product.price = -1
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"], product.errors[:price]
    product.price = 0
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"], product.errors[:price]
    product.price = 1
    assert product.valid?
  end
  
  test "image url format" do
    ok = %w{fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg http://a.b.c/x/y/z/fred.gif }
    bad = %w{fred.doc fred.gif/more fred.gif.more }
    # loops
    ok.each do |image_url|
      assert new_product(image_url).valid?, "#{image_url} shouldn't be invalid"
    end
    bad.each do |image_url|
      assert new_product(image_url).invalid?, "#{image_url} shouldn't be valid"
    end
  end
  
  test "product is not valid without a unique title" do
    product = new_product("my_image.jpg")
    product.title = products(:ruby).title
    assert product.invalid?
    assert_equal ["has already been taken"], product.errors[:title]
  end
  
  test "product is not valid without a unique title - i18n" do
    product = new_product("my_image.jpg")
    product.title = products(:ruby).title
    assert product.invalid?
    assert_equal [I18n.translate('errors.messages.taken')], product.errors[:title]
  end

  test "product title is not long enough" do
    product = new_product("my_image.jpg")
    product.title = "Short"
    assert product.invalid?
    assert_equal ["must be a minimum of 10 characters"], product.errors[:title]
  end
end  
