class HomeController < ApplicationController
  def index
    jobs = Job.where.not(deadline: nil).order(deadline: :asc)

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
end