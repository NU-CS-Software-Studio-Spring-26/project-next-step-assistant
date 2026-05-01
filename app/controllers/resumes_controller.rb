class ResumesController < ApplicationController
  before_action :set_job, if: :nested_job_request?
  before_action :set_resume, only: %i[show edit update destroy]

  def index
    @resumes = Resume.with_attached_file.order(created_at: :desc)
  end

  def show
  end

  def new
    @resume = Resume.new
  end

  def edit
  end

  def create
    @resume = Resume.new(resume_params)
    @resume.job_id = @job.id if nested_job_request?

    if @resume.save
      redirect_to nested_job_request? ? @job : resumes_path, notice: "Resume was added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @resume.update(resume_params)
      redirect_to @resume, notice: "Resume updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @resume.destroy!
    redirect_to nested_job_request? ? @job : resumes_path, notice: "Resume was removed.", status: :see_other
  end

  private

  def set_job
    @job = Job.find(params.expect(:job_id))
  end

  def set_resume
    @resume = if nested_job_request?
      @job.resumes.find(params.expect(:id))
    else
      Resume.find(params.expect(:id))
    end
  end

  def resume_params
    params.expect(resume: [ :name, :file ])
  end

  def nested_job_request?
    params[:job_id].present?
  end
end
