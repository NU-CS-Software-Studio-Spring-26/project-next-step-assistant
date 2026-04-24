class HomeController < ApplicationController
  def index
    @deadline_jobs = Job.where.not(deadline: nil).order(deadline: :asc)
  end
end
