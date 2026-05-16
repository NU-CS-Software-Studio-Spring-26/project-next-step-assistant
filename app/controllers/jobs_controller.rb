class JobsController < ApplicationController
  SEARCH_QUERY_MAX_LENGTH = 100

  before_action :authenticate_user!
  before_action :set_job, only: %i[ show edit update destroy ]

  # GET /jobs or /jobs.json
  def index
    @query = params[:query].to_s.strip.first(SEARCH_QUERY_MAX_LENGTH)
    @status = params[:status]
    @jobs = current_user.jobs.order(deadline: :asc)

    if @query.present?
      term = "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
      @jobs = @jobs.where(
        "LOWER(jobs.title) LIKE LOWER(?) OR LOWER(jobs.organization_name) LIKE LOWER(?)",
        term,
        term
      )
    end

    if @status.present?
      @jobs = @jobs.where(status: @status)
    end
  end

  # GET /jobs/1 or /jobs/1.json
  def show
  end

  # GET /jobs/new
  def new
    @job = current_user.jobs.build
  end

  # GET /jobs/1/edit
  def edit
  end

  # POST /jobs or /jobs.json
  def create
    @job = current_user.jobs.build(job_params)

    respond_to do |format|
      if @job.save
        format.html { redirect_to job_path(@job), notice: "Job was successfully created." }
        format.json { render :show, status: :created, location: @job }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1 or /jobs/1.json
  def update
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to job_path(@job), notice: "Job was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render(params[:from_show].present? ? :show : :edit, status: :unprocessable_entity) }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1 or /jobs/1.json
  def destroy
    @job.destroy!

    respond_to do |format|
      format.html { redirect_to jobs_path, notice: "Job was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = current_user.jobs.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def job_params
      permitted = params.expect(job: [ :title, :organization_name, :deadline, :start_date, :description, :status, :resume_id ])
      if permitted[:resume_id].present?
        rid = permitted[:resume_id].to_i
        permitted[:resume_id] = current_user.resumes.exists?(rid) ? rid : nil
      end
      permitted
    end
end
