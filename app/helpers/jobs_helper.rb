module JobsHelper
  JOB_STATUSES = [
    "Saved",
    "Applied",
    "Interviewing",
    "Offer",
    "Accepted",
    "Rejected",
    "Withdrawn"
  ].freeze

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
