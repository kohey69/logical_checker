class User < ApplicationRecord
  has_secure_token :api_token

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :api_token, presence: true, uniqueness: true
end
