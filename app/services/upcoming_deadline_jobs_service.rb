# Returns a user's jobs with deadlines in the upcoming reminder window,
# excluding terminal pipeline statuses.
class UpcomingDeadlineJobsService
  REMINDER_WINDOW_DAYS = 3
  EXCLUDED_STATUSES = %w[rejected withdrawn accepted].freeze

  def initialize(user, as_of: Date.current)
    @user = user
    @as_of = as_of
  end

  def call
    window_end = @as_of + REMINDER_WINDOW_DAYS

    @user.jobs
      .where.not(deadline: nil)
      .where(deadline: @as_of..window_end)
      .where.not(status: EXCLUDED_STATUSES)
      .order(deadline: :asc)
  end
end
