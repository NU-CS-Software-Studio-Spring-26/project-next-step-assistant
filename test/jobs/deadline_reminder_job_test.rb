require "test_helper"

class DeadlineReminderJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  setup do
    @user = users(:one)
    @as_of = Date.new(2026, 4, 15)
  end

  test "sends email when upcoming jobs exist" do
    travel_to @as_of do
      jobs(:one).update!(deadline: @as_of + 3.days, status: :applied)

      assert_emails 1 do
        DeadlineReminderJob.perform_now(@user.id)
      end
    end
  end

  test "does not send when no upcoming jobs" do
    travel_to @as_of do
      @user.jobs.update_all(deadline: @as_of + 30.days)

      assert_no_emails do
        DeadlineReminderJob.perform_now(@user.id)
      end
    end
  end

  test "does nothing for invalid user id" do
    assert_no_emails do
      DeadlineReminderJob.perform_now(-1)
    end
  end
end
