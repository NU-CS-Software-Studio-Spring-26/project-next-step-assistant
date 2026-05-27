class JobsController < ApplicationController
  SEARCH_QUERY_MAX_LENGTH = 100

  before_action :authenticate_user!
  before_action :set_job, only: %i[ show edit update destroy update_status ]
  before_action :set_job_match, only: %i[ show update ]

  # GET /jobs or /jobs.json
  def index
    @query = params[:query].to_s.strip.first(SEARCH_QUERY_MAX_LENGTH)
    @status = normalize_status_filter(params[:status])
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
    @pagy, @jobs = pagy(@jobs)
  end

  # GET /jobs/1 or /jobs/1.json
  def show
  end

  # GET /jobs/1/ai_resume_suggestions
  def ai_resume_suggestions
    @job = current_user.jobs.find(params.expect(:id))
    @result = AiResumeSuggestionsService.new(@job).call
  end

  # GET/POST /jobs/import
  def import
    @job_text = params[:job_text].to_s
    @greenhouse_url = params[:greenhouse_url].to_s
    return unless request.post? && params[:job_text].present?

    @result = JobImportService.new(@job_text).call
    if @result.state == :ready
      redirect_to new_job_path(job: @result.attributes), notice: "Review the imported fields and save."
    else
      render :import, status: :unprocessable_entity
    end
  end

  # POST /jobs/import_greenhouse
  def import_greenhouse
    @greenhouse_url = params[:greenhouse_url].to_s
    @result = GreenhouseJobImportService.new(@greenhouse_url).call

    if @result.state == :ready
      redirect_to new_job_path(job: @result.attributes), notice: "Review imported job details."
    else
      redirect_to import_jobs_path, alert: @result.message.presence || "Unable to import Greenhouse listing."
    end
  end

  # GET /jobs/new
  def new
    @job = current_user.jobs.build(prefill_params)
  end

  # GET /jobs/1/edit
  def edit
  end

  # POST /jobs or /jobs.json
  def create
    attrs = job_params
    new_resume_file = attrs.delete(:new_resume_file)
    new_resume_name = attrs.delete(:new_resume_name)
    @job = current_user.jobs.build(attrs)
    attach_new_resume(new_resume_file, new_resume_name) if new_resume_file.present?

    respond_to do |format|
      if @job.errors.empty? && @job.save
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
    attrs = job_params
    new_resume_file = attrs.delete(:new_resume_file)
    new_resume_name = attrs.delete(:new_resume_name)
    @job.assign_attributes(attrs)
    attach_new_resume(new_resume_file, new_resume_name) if new_resume_file.present?

    respond_to do |format|
      if @job.errors.empty? && @job.save
        format.html { redirect_to job_path(@job), notice: "Job was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render(params[:from_show].present? ? :show : :edit, status: :unprocessable_entity) }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /jobs/1/update_status — quick status change from the badge dropdown.
  def update_status
    new_status = params[:status].to_s
    if Job.statuses.key?(new_status) && @job.update(status: new_status)
      redirect_back fallback_location: job_path(@job), notice: "Status updated to \"#{new_status.titleize}\".", status: :see_other
    else
      redirect_back fallback_location: job_path(@job), alert: @job.errors.full_messages.to_sentence.presence || "Could not update status.", status: :see_other
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
      scope = current_user.jobs
      if action_name.in?(%w[show update])
        scope = scope.includes(resume: { file_attachment: :blob })
      end
      @job = scope.find(params.expect(:id))
    end

    def normalize_status_filter(raw)
      return nil if raw.blank?

      key = raw.to_s.strip.downcase
      Job.statuses[key] ? key : nil
    end

    def set_job_match
      return unless @job

      @job_match = JobMatchService.new(
        @job,
        projects: current_user.projects,
        resumes: current_user.resumes.includes(file_attachment: :blob)
      ).call
    end

    # Only allow a list of trusted parameters through.
    def job_params
      permitted = params.expect(job: [ :title, :organization_name, :deadline, :start_date, :description, :status, :source, :resume_id, :new_resume_file, :new_resume_name ])
      if permitted[:status].present? && !Job.statuses.value?(permitted[:status].to_s)
        permitted.delete(:status)
      end
      if permitted[:resume_id].present?
        rid = permitted[:resume_id].to_s.to_i
        permitted[:resume_id] = current_user.resumes.exists?(rid) ? rid : nil
      end
      permitted
    end

    # Whitelisted query-string pre-fills for /jobs/new (used by Quick Import).
    def prefill_params
      return {} unless params[:job].is_a?(ActionController::Parameters) || params[:job].is_a?(Hash)
      params.require(:job).permit(:title, :organization_name, :deadline, :start_date, :description, :source)
    end

    # Creates a new Resume from the inline upload fields on the job form and
    # links it to @job. Resume validation errors are surfaced on @job so the
    # form re-renders with the issue.
    def attach_new_resume(file, name)
      resume_name = name.presence || file.original_filename.to_s.sub(/\.pdf\z/i, "").presence || "Resume"
      resume = current_user.resumes.build(name: resume_name, file: file)
      if resume.save
        @job.resume = resume
      else
        resume.errors.full_messages.each { |msg| @job.errors.add(:base, "New resume: #{msg}") }
      end
    end
end
