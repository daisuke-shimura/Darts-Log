require "test_helper"

class Games::ShootOutsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get games_shoot_outs_new_url
    assert_response :success
  end

  test "should get show" do
    get games_shoot_outs_show_url
    assert_response :success
  end
end
