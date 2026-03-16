class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient

  # Validations
  validates :recipe_id, presence: true
  validates :ingredient_id, presence: true
end