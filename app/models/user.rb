# frozen_string_literal: true
class User < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
  has_secure_password

  after_destroy :ensure_an_admin_remains

  class Error < StandardError
  end

  def ensure_an_admin_remains
    if User.count.zero?
      raise Error, "Can't delete last user!"
    end
  end
end
