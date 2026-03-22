class RecipesController < ApplicationController
  def menu
    @recipes = Recipe.includes(:category, :area).limit(50)
  end
end
