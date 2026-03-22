class RecipesController < ApplicationController
  def menu
    @recipes = Recipe.includes(:category, :area).limit(50)
  end

  def show
    @recipe = Recipe.find(params[:id])
  end
end
