class Area < ApplicationRecord
  has_many :recipes

  # Validations
  validates :name, presence: true, uniqueness: true
end