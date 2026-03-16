class Area < ApplicationRecord
  has_many :recipes

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :id_from_api, presence: true
end