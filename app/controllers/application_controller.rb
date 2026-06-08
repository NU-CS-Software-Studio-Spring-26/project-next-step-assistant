class ApplicationController < ActionController::Base
  include Pagy::Backend
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_password_setup, if: :user_signed_in?

  private

  def require_password_setup
    return unless current_user.needs_password_setup?
    return if password_setup_exempt_request?

    redirect_to new_password_setup_path,
      notice: "Please set a password for your account before continuing."
  end

  def password_setup_exempt_request?
    devise_controller? ||
      controller_path == "users/password_setups" ||
      controller_path == "users/omniauth_callbacks" ||
      request.path == destroy_user_session_path
  end
end
