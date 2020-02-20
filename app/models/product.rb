class Product < ApplicationRecord
  validates :title, :description, :image_url, presence: true
  validates :title, uniqueness: { case_sensitive: false }
  validates :title, length: { minimum: 10, too_short: "must be a minimum of %{count} characters" }
  validates :image_url, allow_blank: true, format: {
    with: %r{\.(gif|jpg|png)\Z}i,
    message: 'must be a url for gif, jpg or png image.'
  }
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
end
