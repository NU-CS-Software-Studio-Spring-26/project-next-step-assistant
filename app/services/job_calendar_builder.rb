require "icalendar"

# Renders a user's job deadlines and start dates as an iCalendar (ICS) feed
# that calendar apps (Google, Apple, Outlook) can subscribe to. Stable UIDs
# let calendar apps update existing events on re-poll instead of duplicating.
class JobCalendarBuilder
  PRODID = "-//Next Step Assistant//Job deadlines//EN".freeze
  CAL_NAME = "Next Step Assistant — Job deadlines".freeze

  def initialize(user, host: nil)
    @user = user
    @host = host || ENV.fetch("APP_HOST", "localhost:3000")
  end

  def to_ics
    cal = Icalendar::Calendar.new
    cal.append_custom_property("X-WR-CALNAME", CAL_NAME)
    cal.prodid = PRODID

    deadline_jobs.find_each { |job| add_deadline_event(cal, job) }
    start_date_jobs.find_each { |job| add_start_date_event(cal, job) }

    cal.publish
    cal.to_ical
  end

  private

  def deadline_jobs
    @user.jobs.where.not(deadline: nil)
  end

  def start_date_jobs
    @user.jobs.where.not(start_date: nil)
  end

  def add_deadline_event(cal, job)
    cal.event do |e|
      e.dtstart = Icalendar::Values::Date.new(job.deadline)
      e.dtend   = Icalendar::Values::Date.new(job.deadline + 1)
      e.summary = "Apply: #{event_subject(job)}"
      e.url     = job_url_for(job)
      e.uid     = "job-deadline-#{job.id}@next-step-assistant"
    end
  end

  def add_start_date_event(cal, job)
    cal.event do |e|
      e.dtstart = Icalendar::Values::Date.new(job.start_date)
      e.dtend   = Icalendar::Values::Date.new(job.start_date + 1)
      e.summary = "Start: #{event_subject(job)}"
      e.url     = job_url_for(job)
      e.uid     = "job-start-#{job.id}@next-step-assistant"
    end
  end

  def event_subject(job)
    [ job.title.presence, job.organization_name.presence ].compact.join(" @ ").presence || "Untitled job"
  end

  def job_url_for(job)
    Rails.application.routes.url_helpers.job_url(job, host: @host)
  end
end
