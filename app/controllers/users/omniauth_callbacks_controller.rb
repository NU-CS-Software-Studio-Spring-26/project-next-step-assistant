# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def github
      @user = User.from_omniauth(request.env["omniauth.auth"], current_user: current_user)

      if @user.persisted? && @user.errors.empty?
        sign_in @user, event: :authentication
        set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?

        if @user.needs_password_setup?
          redirect_to new_password_setup_path,
            notice: "Signed in with GitHub. Set a password for this website to finish setting up your account."
        else
          redirect_to after_sign_in_path_for(@user), allow_other_host: false
        end
      else
        message = @user.errors.full_messages.presence&.to_sentence ||
          "Could not sign in with GitHub."
        redirect_to new_user_session_path, alert: message
      end
    end

    def failure
      redirect_to new_user_session_path,
        alert: "GitHub sign-in was cancelled or failed. Please try again or use email and password."
    end
  end
end
