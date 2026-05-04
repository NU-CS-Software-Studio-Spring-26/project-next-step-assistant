class HomeController < ApplicationController
  def index
    @start_date = parse_date(params[:start_date]) || Date.current
    @end_date = parse_date(params[:end_date]) || 3.months.from_now.to_date

    jobs = if user_signed_in?
      current_user.jobs
        .where.not(deadline: nil)
        .where(deadline: @start_date..@end_date)
        .order(deadline: :asc)
    else
      Job.none
    end

    @deadline_items = jobs.map do |job|
      {
        kind: "Job",
        title: job.title,
        subtitle: job.organization_name,
        deadline: job.deadline,
        path: job_path(job)
      }
    end
  end

  private

  def parse_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end
end
