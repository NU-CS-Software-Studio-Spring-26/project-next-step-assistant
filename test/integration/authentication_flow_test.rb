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
