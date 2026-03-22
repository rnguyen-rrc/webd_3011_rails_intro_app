class RecipesController < ApplicationController
  def menu
    @recipes = Recipe
      .left_joins(:category)
      .left_joins(:ingredients)
      .left_joins(:tags)
      .left_joins(:area)
      .distinct

    if params[:query].present?
      q = "%#{params[:query]}%"

      @recipes = @recipes.where(
        "recipes.name LIKE :q
        OR categories.name LIKE :q
        OR ingredients.name LIKE :q
        OR tags.name LIKE :q
        OR areas.name LIKE :q",
        q: q
      )
    end

    if params[:category].present?
      @recipes = @recipes.where(category_id: params[:category])
    end

    @recipes = @recipes.page(params[:page]).per(8)
  end

  def show
    @recipe = Recipe.find(params[:id])
  end
end
