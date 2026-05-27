class DeadlineRemindersDispatchJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      DeadlineReminderJob.perform_later(user.id)
    end
  end
end
