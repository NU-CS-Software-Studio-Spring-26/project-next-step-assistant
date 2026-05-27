class DeadlineMailer < ApplicationMailer
  def reminder(user, jobs)
    @user = user
    @jobs = jobs

    mail(to: user.email, subject: reminder_subject(jobs))
  end

  private

  def reminder_subject(jobs)
    count = jobs.size
    if count == 1
      "1 job deadline coming up"
    else
      "#{count} job deadlines coming up"
    end
  end
end
