class AreasController < ApplicationController
  def index
    @areas = Area.joins(:recipes).distinct
  end

  def show
    @area = Area.find(params[:id])
    @recipes = @area.recipes
  end
end