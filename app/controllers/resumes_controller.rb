class ResumesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, if: :nested_job_request?
  before_action :set_resume, only: %i[show edit update destroy]

  def index
    @resumes = current_user.resumes.with_attached_file.order(created_at: :desc)
  end

  def show
  end

  def new
    @resume = current_user.resumes.build
  end

  def edit
  end

  def create
    @resume = current_user.resumes.build(resume_params)
    @resume.job_id = @job.id if nested_job_request?

    if @resume.save
      redirect_to nested_job_request? ? @job : resumes_path, notice: "Resume was added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    attrs = resume_params
    attrs = attrs.except(:file) if attrs[:file].blank?

    if @resume.update(attrs)
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
    @job = current_user.jobs.find(params.expect(:job_id))
  end

  def set_resume
    @resume = if nested_job_request?
      @job.resumes.find(params.expect(:id))
    else
      current_user.resumes.find(params.expect(:id))
    end
  end

  def resume_params
    params.expect(resume: [ :name, :file ])
  end

  def nested_job_request?
    params[:job_id].present?
  end
end
