require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "shows signed in user deadlines" do
    sign_in users(:one)
    get root_url, params: { start_date: "2026-01-01", end_date: "2026-12-31" }
    assert_response :success
    assert_includes response.body, jobs(:one).title
  end

  test "ignores invalid date filter params" do
    sign_in users(:one)
    get root_url, params: { start_date: "not-a-date", end_date: "also-bad" }
    assert_response :success
  end
end
