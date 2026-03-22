# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# This file should ensure the existence of records required to run the application in every environment.
# The data can be loaded with:
#   rails db:seed

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# This file should ensure the existence of records required to run the application in every environment.
# The data can be loaded with:
#   rails db:seed

require 'httparty'
require 'faker'

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
  Area.find_or_create_by!(name: a["strArea"])
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

tags = 15.times.map { Faker::Food.spice }.uniq

tags.each do |tag_name|
  Tag.find_or_create_by!(name: tag_name)
end

puts "Tags created."

# assign random tags to recipes
Recipe.find_each do |recipe|
  Tag.order("RANDOM()").limit(2).each do |tag|
    RecipeTag.find_or_create_by!(
      recipe: recipe,
      tag: tag
    )
  end
end

puts "Tags assigned."

areas = {
  "American" => [37.0902, -95.7129],
  "British" => [55.3781, -3.4360],
  "Canadian" => [56.1304, -106.3468],
  "Chinese" => [35.8617, 104.1954],
  "Croatian" => [45.1000, 15.2000],
  "Dutch" => [52.1326, 5.2913],
  "Egyptian" => [26.8206, 30.8025],
  "Filipino" => [12.8797, 121.7740],
  "French" => [46.6034, 1.8883],
  "Greek" => [39.0742, 21.8243],
  "Indian" => [20.5937, 78.9629],
  "Irish" => [53.1424, -7.6921],
  "Italian" => [41.8719, 12.5674],
  "Jamaican" => [18.1096, -77.2975],
  "Japanese" => [36.2048, 138.2529],
  "Kenyan" => [-0.0236, 37.9062],
  "Malaysian" => [4.2105, 101.9758],
  "Mexican" => [23.6345, -102.5528],
  "Moroccan" => [31.7917, -7.0926],
  "Polish" => [51.9194, 19.1451],
  "Portuguese" => [39.3999, -8.2245],
  "Russian" => [61.5240, 105.3188],
  "Spanish" => [40.4637, -3.7492],
  "Thai" => [15.8700, 100.9925],
  "Tunisian" => [33.8869, 9.5375],
  "Turkish" => [38.9637, 35.2433],
  "Vietnamese" => [14.0583, 108.2772]
}

areas.each do |name, coords|
  area = Area.find_by(name: name)
  if area
    area.update(latitude: coords[0], longitude: coords[1])
  end
end

puts "Area's latitude & longitude assigned."

puts "Seeding completed successfully."