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

# -------------------------------------------------
# DATA SOURCE 6 - API (latitude, longitude for Areas)
# -------------------------------------------------

puts "Fetching coordinates for areas..."

require "net/http"
require "json"

area_to_code = {
  "Algerian"      => "DZ",
  "American"      => "US",
  "Argentinian"   => "AR",
  "Australian"    => "AU",
  "British"       => "GB",
  "Canadian"      => "CA",
  "Chinese"       => "CN",
  "Croatian"      => "HR",
  "Dutch"         => "NL",
  "Egyptian"      => "EG",
  "Filipino"      => "PH",
  "French"        => "FR",
  "Greek"         => "GR",
  "Indian"        => "IN",
  "Irish"         => "IE",
  "Italian"       => "IT",
  "Jamaican"      => "JM",
  "Japanese"      => "JP",
  "Kenyan"        => "KE",
  "Malaysian"     => "MY",
  "Mexican"       => "MX",
  "Moroccan"      => "MA",
  "Norwegian"     => "NO",
  "Polish"        => "PL",
  "Portuguese"    => "PT",
  "Russian"       => "RU",
  "Saudi Arabian" => "SA",
  "Slovakian"     => "SK",
  "Spanish"       => "ES",
  "Syrian"        => "SY",
  "Thai"          => "TH",
  "Tunisian"      => "TN",
  "Turkish"       => "TR",
  "Ukrainian"     => "UA",
  "Uruguayan"     => "UY",
  "Venezulan"     => "VE"
  "Vietnamese"    => "VN"
}

Area.find_each do |area|
  code = area_to_code[area.name]

  unless code
    puts "No code mapping for #{area.name}"
    next
  end

  url = URI("https://restcountries.com/v3.1/alpha/#{code}")

  begin
    response = Net::HTTP.get_response(url)

    unless response.is_a?(Net::HTTPSuccess)
      puts "Failed API for #{area.name}"
      next
    end

    data = JSON.parse(response.body)
    latlng = data[0]["latlng"]

    if latlng && latlng.length == 2
      area.update!(
        latitude: latlng[0],
        longitude: latlng[1]
      )
      puts "#{area.name} → #{latlng[0]}, #{latlng[1]}"
    else
      puts "No latlng for #{area.name}"
    end

    sleep(0.1)

  rescue => e
    puts "Error for #{area.name}: #{e.message}"
  end
end

puts "Area's latitude & longitude assigned."

puts "Seeding completed successfully."