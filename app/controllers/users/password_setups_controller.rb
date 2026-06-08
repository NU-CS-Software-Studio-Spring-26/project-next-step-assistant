# frozen_string_literal: true

module Users
  class PasswordSetupsController < ApplicationController
    before_action :authenticate_user!
    before_action :redirect_if_password_already_set, only: %i[ new create ]

    def new
    end

    def create
      current_user.password = password_setup_params[:password]
      current_user.password_confirmation = password_setup_params[:password_confirmation]

      if current_user.save
        current_user.mark_password_as_set!
        redirect_to after_password_setup_path, notice: "Your account password has been set. You can sign in with email and password or GitHub."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def redirect_if_password_already_set
      return if current_user.needs_password_setup?

      redirect_to root_path
    end

    def password_setup_params
      params.expect(user: [ :password, :password_confirmation ])
    end

    def after_password_setup_path
      stored_location_for(:user) || root_path
    end
  end
end
