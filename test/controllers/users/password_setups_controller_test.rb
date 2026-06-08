require "test_helper"

module Users
  class PasswordSetupsControllerTest < ActionDispatch::IntegrationTest
    test "new requires authentication" do
      get new_password_setup_path
      assert_redirected_to new_user_session_path
    end

    test "github user without password is redirected to password setup" do
      oauth_password = User.oauth_password
      user = User.create!(
        email: "oauth-only@example.com",
        provider: "github",
        uid: "gh-setup",
        password: oauth_password,
        password_confirmation: oauth_password
      )
      sign_in user

      get root_path
      assert_redirected_to new_password_setup_path
    end

    test "create sets password and clears setup requirement" do
      oauth_password = User.oauth_password
      user = User.create!(
        email: "oauth-setup@example.com",
        provider: "github",
        uid: "gh-setup-2",
        password: oauth_password,
        password_confirmation: oauth_password
      )
      sign_in user

      post password_setup_path, params: {
        user: { password: "Password1!", password_confirmation: "Password1!" }
      }

      assert_redirected_to root_path
      user.reload
      assert_not user.needs_password_setup?
      assert user.valid_password?("Password1!")
    end

    test "users with password already set cannot access setup page" do
      sign_in users(:one)

      get new_password_setup_path
      assert_redirected_to root_path
    end
  end
end
