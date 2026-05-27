module JobsHelper
  def job_status_options
    Job.statuses.keys.map { |key| [ key.titleize, key ] }
  end

  def job_status_label(status)
    status.to_s.titleize
  end

  def job_match_level_label(level)
    case level.to_s
    when "high" then "High"
    when "medium" then "Medium"
    when "low" then "Low"
    else "Unknown"
    end
  end

  def job_match_level_badge_class(level)
    case level.to_s
    when "high" then "text-bg-success"
    when "medium" then "text-bg-warning"
    when "low" then "text-bg-secondary"
    else "text-bg-light border"
    end
  end

  def job_status_badge_class(status)
    case status.to_s.strip.downcase
    when "saved"        then "text-bg-secondary"
    when "applied"      then "text-bg-info"
    when "interviewing" then "text-bg-warning"
    when "offer"        then "text-bg-primary"
    when "accepted"     then "text-bg-success"
    when "rejected"     then "text-bg-danger"
    when "withdrawn"    then "text-bg-dark"
    else                     "text-bg-light border"
    end
  end

  def job_status_icon(status)
    case status.to_s.strip.downcase
    when "saved"        then "bi-bookmark"
    when "applied"      then "bi-send"
    when "interviewing" then "bi-people"
    when "offer"        then "bi-envelope-paper"
    when "accepted"     then "bi-check-circle"
    when "rejected"     then "bi-x-circle"
    when "withdrawn"    then "bi-slash-circle"
    else                     "bi-circle"
    end
  end

  # Renders the job's status as a Bootstrap dropdown. Clicking the badge opens
  # a menu of all statuses; selecting one PATCHes update_status and redirects
  # back to wherever the click came from. `extra_classes` (e.g. "fs-6") lets
  # callers match the show-page sizing.
  def job_status_badge_dropdown(job, extra_classes: "")
    render partial: "jobs/status_badge_dropdown", locals: { job: job, extra_classes: extra_classes }
  end
end
