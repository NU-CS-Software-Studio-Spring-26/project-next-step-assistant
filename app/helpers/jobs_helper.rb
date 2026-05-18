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
end
