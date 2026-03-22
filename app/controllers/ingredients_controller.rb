class IngredientsController < ApplicationController
  def index
    @ingredients = Ingredient
                    .joins(:recipes)
                    .distinct
                    .page(params[:page])
                    .per(20)
  end

  def show
    @ingredient = Ingredient.find(params[:id])
    @recipes = @ingredient.recipes
  end
end