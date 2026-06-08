require "test_helper"

module Users
  class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
    setup do
      OmniAuth.config.test_mode = true
    end

    teardown do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:github] = nil
    end

    test "github callback signs in user with matching email" do
      user = users(:one)
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "integration-gh-1",
        info: OmniAuth::AuthHash::InfoHash.new(email: user.email)
      )

      get user_github_omniauth_callback_path

      assert_redirected_to root_path
      follow_redirect!
      assert_response :success
    end

    test "github callback creates and signs in a new user" do
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "integration-gh-new",
        info: OmniAuth::AuthHash::InfoHash.new(email: "brand-new-github@example.com")
      )

      assert_difference("User.count", 1) do
        get user_github_omniauth_callback_path
      end

      assert_redirected_to new_password_setup_path
      user = User.find_by(email: "brand-new-github@example.com")
      assert user.github_connected?
      assert user.needs_password_setup?
    end

    test "github callback links github to signed in user" do
      user = users(:two)
      sign_in user

      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "integration-gh-link",
        info: OmniAuth::AuthHash::InfoHash.new(email: "different@example.com")
      )

      get user_github_omniauth_callback_path

      assert_redirected_to root_path
      assert user.reload.github_connected?
    end

    test "github callback redirects with alert when email missing" do
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "integration-gh-no-email",
        info: OmniAuth::AuthHash::InfoHash.new(email: nil)
      )

      assert_no_difference("User.count") do
        get user_github_omniauth_callback_path
      end

      assert_redirected_to new_user_session_path
      follow_redirect!
      assert_match(/GitHub|email/i, flash[:alert].to_s)
    end

    test "failure redirects to sign in with message" do
      OmniAuth.config.mock_auth[:github] = :invalid_credentials

      get user_github_omniauth_callback_path

      assert_redirected_to new_user_session_path
      follow_redirect!
      assert_match(/GitHub|cancelled|failed/i, flash[:alert].to_s)
    end
  end
end
