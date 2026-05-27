require "test_helper"

class DeadlineRemindersDispatchJobTest < ActiveJob::TestCase
  test "enqueues reminder job for each user" do
    assert_enqueued_jobs User.count, only: DeadlineReminderJob do
      DeadlineRemindersDispatchJob.perform_now
    end
  end
end
