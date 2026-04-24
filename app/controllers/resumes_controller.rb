class ResumesController < ApplicationController
  before_action :set_job
  before_action :set_resume, only: %i[destroy]

  def new
    @resume = @job.resumes.build
  end

  def create
    @resume = @job.resumes.build(resume_params)

    if @resume.save
      redirect_to @job, notice: "Resume was added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @resume.destroy!
    redirect_to @job, notice: "Resume was removed.", status: :see_other
  end

  private

  def set_job
    @job = Job.find(params.expect(:job_id))
  end

  def set_resume
    @resume = @job.resumes.find(params.expect(:id))
  end

  def resume_params
    params.expect(resume: [:file])
  end
end
