# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'httparty'
require 'faker'
require 'securerandom'

puts "Cleaning database..."

RecipeTag.destroy_all
RecipeIngredient.destroy_all
Recipe.destroy_all
Ingredient.destroy_all
Category.destroy_all
Area.destroy_all
Tag.destroy_all

puts "Database cleaned."

# -------------------------------------------------
# DATA SOURCE 1 - API (Categories)
# -------------------------------------------------

puts "Loading categories..."

categories_url = "https://www.themealdb.com/api/json/v1/1/list.php?c=list"
categories = HTTParty.get(categories_url)

categories["meals"].each do |c|
  Category.find_or_create_by!(name: c["strCategory"]) do |category|
    category.id_from_api = SecureRandom.uuid
    category.img_url = ""
    category.description = "Imported from MealDB"
  end
end

puts "Categories created."

# -------------------------------------------------
# DATA SOURCE 2 - API (Areas)
# -------------------------------------------------

puts "Loading areas..."

areas_url = "https://www.themealdb.com/api/json/v1/1/list.php?a=list"
areas = HTTParty.get(areas_url)

areas["meals"].each do |a|
  Area.find_or_create_by!(name: a["strArea"]) do |area|
    area.id_from_api = SecureRandom.uuid
  end
end

puts "Areas created."

# -------------------------------------------------
# DATA SOURCE 3 - API (Ingredients)
# -------------------------------------------------

puts "Loading ingredients..."

ingredients_url = "https://www.themealdb.com/api/json/v1/1/list.php?i=list"
ingredients = HTTParty.get(ingredients_url)

ingredients["meals"].each do |i|
  Ingredient.find_or_create_by!(
    name: i["strIngredient"]
  )
end

puts "Ingredients created."

# -------------------------------------------------
# DATA SOURCE 4 - API (Meals / Recipes)
# -------------------------------------------------

puts "Loading recipes..."

recipes_url = "https://www.themealdb.com/api/json/v1/1/search.php?s="
recipes = HTTParty.get(recipes_url)

recipes["meals"].each do |meal|

  category = Category.find_by(name: meal["strCategory"])
  area = Area.find_by(name: meal["strArea"])

  recipe = Recipe.find_or_create_by!(id_from_api: meal["idMeal"]) do |r|
    r.name = meal["strMeal"]
    r.alternate_name = meal["strMealAlternate"]
    r.category = category
    r.area = area
    r.instructions = meal["strInstructions"]
    r.img_url = meal["strMealThumb"]
  end

  # ingredients + measures
  (1..20).each do |i|
    ingredient_name = meal["strIngredient#{i}"]
    measure = meal["strMeasure#{i}"]

    next if ingredient_name.blank? || ingredient_name.strip.empty?

    ingredient = Ingredient.find_by(name: ingredient_name.strip)
    ingredient ||= Ingredient.create!(name: ingredient_name.strip)

    RecipeIngredient.find_or_create_by!(
      recipe: recipe,
      ingredient: ingredient
    ) do |ri|
      ri.measure = measure
    end
  end
end

puts "Recipes created."

# -------------------------------------------------
# DATA SOURCE 5 - Faker (Tags)
# -------------------------------------------------

puts "Generating tags..."

15.times do
  Tag.find_or_create_by!(
    name: Faker::Food.spice
  )
end

puts "Tags created."

# assign random tags to recipes
Recipe.all.each do |recipe|
  Tag.order("RANDOM()").limit(2).each do |tag|
    RecipeTag.find_or_create_by!(
      recipe: recipe,
      tag: tag
    )
  end
end

puts "Tags assigned."

puts "Seeding completed successfully."