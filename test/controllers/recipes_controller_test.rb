require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  test "should get menu" do
    get recipes_menu_url
    assert_response :success
  end
end
