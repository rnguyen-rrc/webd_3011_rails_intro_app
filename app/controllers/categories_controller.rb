class CategoriesController < ApplicationController
  def index
    @categories = Category.joins(:recipes).distinct
  end

  def show
    @category = Category.find(params[:id])
    @recipes = @category.recipes
  end
end