class Category < ApplicationRecord
  has_many :recipes

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end