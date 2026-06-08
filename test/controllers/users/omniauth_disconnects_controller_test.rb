require "test_helper"

module Users
  class OmniauthDisconnectsControllerTest < ActionDispatch::IntegrationTest
    test "disconnect clears github provider when password is valid" do
      user = users(:one)
      user.update!(provider: "github", uid: "gh-disconnect", password_set_at: Time.current)
      sign_in user

      delete github_disconnect_path, params: { current_password: "password123" }

      assert_redirected_to edit_user_registration_path
      assert_not user.reload.github_connected?
    end

    test "disconnect requires authentication" do
      delete github_disconnect_path, params: { current_password: "password123" }
      assert_redirected_to new_user_session_path
    end

    test "disconnect rejects invalid password" do
      user = users(:one)
      user.update!(provider: "github", uid: "gh-disconnect", password_set_at: Time.current)
      sign_in user

      delete github_disconnect_path, params: { current_password: "wrong-password" }

      assert_redirected_to edit_user_registration_path
      assert user.reload.github_connected?
    end
  end
end
