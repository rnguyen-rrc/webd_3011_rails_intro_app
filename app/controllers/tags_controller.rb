class TagsController < ApplicationController
  def index
    @tags = Tag.joins(:recipes).distinct
  end

  def show
    @tag = Tag.find(params[:id])
    @recipes = @tag.recipes
  end
end