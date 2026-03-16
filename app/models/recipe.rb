class Recipe < ApplicationRecord
  belongs_to :category
  belongs_to :area

  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  has_many :recipe_tags, dependent: :destroy
  has_many :tags, through: :recipe_tags

  # Validations
  validates :name, presence: true
  validates :instructions, presence: true
end