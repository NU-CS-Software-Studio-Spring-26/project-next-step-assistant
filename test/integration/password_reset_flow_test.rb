require "test_helper"

class PasswordResetFlowTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "password reset request page renders" do
    get new_user_password_path
    assert_response :success
    assert_match(/Forgot your password/i, response.body)
  end

  test "password reset request sends email" do
    assert_emails 1 do
      post user_password_path, params: { user: { email: users(:one).email } }
    end

    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_match(/instructions/i, flash[:notice].to_s)

    mail = ActionMailer::Base.deliveries.last
    body = mail.body.encoded
    assert_match(/reset_password_token/, body)
  end

  test "password reset email link allows setting a new password" do
    post user_password_path, params: { user: { email: users(:one).email } }

    mail = ActionMailer::Base.deliveries.last
    body = mail.body.encoded
    reset_path = body[/href="([^"]+reset_password_token[^"]+)"/, 1] || body[%r{(/users/password/edit\?reset_password_token=[^\s"']+)}]
    assert reset_path.present?

    get reset_path
    assert_response :success
    assert_match(/Choose a new password/i, response.body)

    token = reset_path[/reset_password_token=([^&"]+)/, 1]
    put user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "Newpass1!",
        password_confirmation: "Newpass1!"
      }
    }

    assert_redirected_to root_path
    assert users(:one).reload.valid_password?("Newpass1!")
  end
end
