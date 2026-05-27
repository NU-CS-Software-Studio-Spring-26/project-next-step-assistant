class DashboardController < ApplicationController
  include JobsHelper

  before_action :authenticate_user!

  def index
    @jobs_by_status = jobs_by_status_counts
    @jobs_by_status_chart = @jobs_by_status.transform_keys { |status| job_status_label(status) }
    @jobs_by_month = jobs_by_month_counts
    @total_jobs = current_user.jobs.count
  end

  private

  def jobs_by_status_counts
    counts = current_user.jobs.group(:status).count
    Job.statuses.keys.index_with { |status| counts[status] || 0 }
  end

  def jobs_by_month_counts
    current_user.jobs.group_by_month(:created_at, last: 12).count
  end
end
