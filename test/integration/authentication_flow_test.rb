require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  test "sign in page hides github button when oauth is not configured" do
    with_env("GITHUB_CLIENT_ID" => nil, "GITHUB_CLIENT_SECRET" => nil) do
      get new_user_session_path
      assert_response :success
      assert_no_match(/Sign in with GitHub/i, response.body)
      assert_no_match(/auth-btn-github/i, response.body)
    end
  end

  test "sign in page shows github button when oauth is configured" do
    with_env("GITHUB_CLIENT_ID" => "test-id", "GITHUB_CLIENT_SECRET" => "test-secret") do
      get new_user_session_path
      assert_response :success
      assert_match(/Sign in with GitHub/i, response.body)
    end
  end

  test "email sign in still works without oauth env vars" do
    with_env("GITHUB_CLIENT_ID" => nil, "GITHUB_CLIENT_SECRET" => nil) do
      post user_session_path, params: {
        user: { email: users(:one).email, password: "password123" }
      }
      assert_redirected_to root_path
    end
  end

  test "account page shows github connect option when oauth is configured" do
    sign_in users(:one)

    with_env("GITHUB_CLIENT_ID" => "test-id", "GITHUB_CLIENT_SECRET" => "test-secret") do
      get edit_user_registration_path
      assert_response :success
      assert_match(/Connect GitHub/i, response.body)
      assert_match(/Sign-in methods/i, response.body)
    end
  end

  test "signed in user sees account settings link in navigation" do
    sign_in users(:one)

    get root_path
    assert_response :success
    assert_match(/Account/i, response.body)
    assert_match edit_user_registration_path, response.body
  end

  test "user can delete their account and associated data" do
    user = users(:one)
    job_id = jobs(:one).id
    sign_in user

    assert_difference("User.count", -1) do
      delete user_registration_path
    end

    assert_redirected_to root_path
    assert_nil User.find_by(id: user.id)
    assert_nil Job.find_by(id: job_id)
    follow_redirect!
    assert_match(/successfully cancelled/i, response.body)
  end

  private

  def with_env(vars)
    previous = vars.keys.index_with { |key| ENV[key] }
    vars.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    yield
  ensure
    previous.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
