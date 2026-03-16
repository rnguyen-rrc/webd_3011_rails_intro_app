class Ingredient < ApplicationRecord
  has_many :recipe_ingredients
  has_many :recipes, through: :recipe_ingredients

  # Validations
  validates :name, presence: true, uniqueness: true
end