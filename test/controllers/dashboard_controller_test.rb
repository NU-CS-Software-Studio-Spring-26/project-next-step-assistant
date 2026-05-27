require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get dashboard_url
    assert_redirected_to new_user_session_path
  end

  test "should get index when signed in" do
    sign_in users(:one)
    get dashboard_url
    assert_response :success
  end

  test "shows dashboard heading" do
    sign_in users(:one)
    get dashboard_url
    assert_select "h1", text: "Dashboard"
  end

  test "includes status summary table for signed in user" do
    sign_in users(:one)
    get dashboard_url
    assert_select "table[aria-label='Job counts by application status']"
    assert_includes response.body, "Applied"
    assert_includes response.body, "Saved"
  end

  test "includes chartkick status chart markup" do
    sign_in users(:one)
    get dashboard_url
    assert_match(/Chartkick.*ColumnChart/, response.body)
    assert_match(/Chartkick.*LineChart/, response.body)
  end

  test "status summary reflects only current user jobs" do
    sign_in users(:one)
    get dashboard_url
    assert_not_includes response.body, jobs(:other_users).title
  end

  test "other user does not see first user job titles in summary" do
    sign_in users(:two)
    get dashboard_url
    assert_not_includes response.body, jobs(:one).title
    assert_not_includes response.body, jobs(:two).title
  end

  test "empty user sees empty state" do
    user = User.create!(
      email: "empty-dashboard@example.com",
      password: "Password1!",
      password_confirmation: "Password1!"
    )
    sign_in user
    get dashboard_url
    assert_response :success
    assert_includes response.body, "No applications to chart yet"
    assert_select "table[aria-label='Job counts by application status']", count: 0
  end

  test "nav includes dashboard link when signed in" do
    sign_in users(:one)
    get dashboard_url
    assert_select "a[href='#{dashboard_path}']", text: /Dashboard/
  end
end
