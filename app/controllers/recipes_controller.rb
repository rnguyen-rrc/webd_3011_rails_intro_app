class RecipesController < ApplicationController
  def menu
    @recipes = Recipe.page(params[:page]).per(8)
  end

  def show
    @recipe = Recipe.find(params[:id])
  end
end
