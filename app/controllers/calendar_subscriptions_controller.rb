class CalendarSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  # GET /calendar_subscription
  def show
    current_user.ensure_calendar_token!
    @feed_url = calendar_feed_url(token: current_user.calendar_token, host: request.host_with_port)
  end

  # POST /calendar_subscription — regenerates the token
  def create
    current_user.regenerate_calendar_token!
    redirect_to calendar_subscription_path, notice: "New subscribe URL generated. The old URL no longer works."
  end

  # DELETE /calendar_subscription — clears the token
  def destroy
    current_user.update!(calendar_token: nil)
    redirect_to calendar_subscription_path, notice: "Calendar subscription disabled."
  end
end
