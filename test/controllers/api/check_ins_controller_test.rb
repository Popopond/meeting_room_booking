require "test_helper"

class Api::CheckInsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_check_ins_create_url
    assert_response :success
  end
end
