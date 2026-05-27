class DeadlineReminderJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    jobs = UpcomingDeadlineJobsService.new(user).call
    return if jobs.none?

    DeadlineMailer.reminder(user, jobs).deliver_now
  end
end
