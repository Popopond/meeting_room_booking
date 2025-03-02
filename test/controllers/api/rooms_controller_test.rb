require "test_helper"

class Api::RoomsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_rooms_index_url
    assert_response :success
  end

  test "should get show" do
    get api_rooms_show_url
    assert_response :success
  end
end
