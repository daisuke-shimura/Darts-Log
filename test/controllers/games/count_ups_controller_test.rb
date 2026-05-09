require "test_helper"

class Games::CountUpsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get games_count_ups_new_url
    assert_response :success
  end

  test "should get show" do
    get games_count_ups_show_url
    assert_response :success
  end
end
