require "test_helper"

class Games::CenterCountUpsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get games_center_count_ups_show_url
    assert_response :success
  end

  test "should get new" do
    get games_center_count_ups_new_url
    assert_response :success
  end
end
