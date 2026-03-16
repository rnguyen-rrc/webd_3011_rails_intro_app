class RecipeTag < ApplicationRecord
  belongs_to :recipe
  belongs_to :tag

  # Validations
  validates :recipe_id, presence: true
  validates :tag_id, presence: true
end