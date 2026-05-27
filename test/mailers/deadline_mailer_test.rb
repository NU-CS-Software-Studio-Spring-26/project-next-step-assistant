require "test_helper"

class DeadlineMailerTest < ActionMailer::TestCase
  test "reminder email" do
    user = users(:one)
    jobs = [ jobs(:one) ]
    email = DeadlineMailer.reminder(user, jobs)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ user.email ], email.to
    assert_equal "1 job deadline coming up", email.subject
    assert_match jobs(:one).title, email.html_part.body.decoded
    assert_match jobs(:one).title, email.text_part.body.decoded
    assert_match jobs(:one).deadline.to_fs(:long), email.html_part.body.decoded
  end

  test "reminder subject pluralizes for multiple jobs" do
    user = users(:one)
    jobs = [ jobs(:one), jobs(:two) ]
    email = DeadlineMailer.reminder(user, jobs)

    assert_equal "2 job deadlines coming up", email.subject
  end
end
