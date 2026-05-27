class CalendarController < ApplicationController
  skip_before_action :authenticate_user!, only: :show, raise: false
  protect_from_forgery with: :null_session

  # GET /calendar/:token.ics
  def show
    user = User.find_by(calendar_token: params[:token])
    return head :not_found if user.nil?

    ics = JobCalendarBuilder.new(user, host: request.host_with_port).to_ics
    response.headers["Content-Type"] = "text/calendar; charset=utf-8"
    response.headers["Content-Disposition"] = 'inline; filename="next-step-assistant.ics"'
    render plain: ics
  end
end
