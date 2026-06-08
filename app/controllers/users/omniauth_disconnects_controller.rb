# frozen_string_literal: true

module Users
  class OmniauthDisconnectsController < ApplicationController
    before_action :authenticate_user!

    def destroy
      unless current_user.github_connected?
        redirect_to edit_user_registration_path, alert: "GitHub is not connected to this account."
        return
      end

      unless current_user.valid_password?(params[:current_password].to_s)
        redirect_to edit_user_registration_path, alert: "Current password is incorrect. If you only use GitHub sign-in, reset your password first."
        return
      end

      current_user.update!(provider: nil, uid: nil)
      redirect_to edit_user_registration_path, notice: "GitHub has been disconnected from your account."
    end
  end
end
