class ProjectsController < ApplicationController
  SEARCH_QUERY_MAX_LENGTH = 100
  FOCUS_MAX_LENGTH = 200

  before_action :authenticate_user!
  before_action :set_project, only: %i[ show edit update destroy ]

  # GET /projects or /projects.json
  def index
    @query = params[:query].to_s.strip.first(SEARCH_QUERY_MAX_LENGTH)
    @projects = current_user.projects.all

    if @query.present?
      term = "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
      @projects = @projects.where(
        "LOWER(projects.name) LIKE LOWER(?) OR LOWER(projects.skills) LIKE LOWER(?)",
        term,
        term
      )
    end
    @pagy, @projects = pagy(@projects)
  end

  # GET /projects/1 or /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = current_user.projects.build(prefill_params)
  end

  # GET /projects/ai_suggestions
  def ai_suggestions
    @available_jobs = current_user.jobs.order(:created_at)
    @focus = params[:focus].to_s.strip.first(FOCUS_MAX_LENGTH)
    submitted_job_ids = Array(params[:job_ids]).map(&:to_i).reject(&:zero?)

    if params[:generate].present?
      @selected_job_ids = submitted_job_ids
      @result = AiProjectSuggestionsService.new(
        current_user,
        job_ids: submitted_job_ids,
        focus: @focus
      ).call
    else
      # Landing on the page (e.g. from a job's "Get project ideas" button) only
      # preselects jobs so the user can adjust the focus before generating.
      # Default to every job ticked when none were passed in.
      @selected_job_ids = submitted_job_ids.presence || @available_jobs.pluck(:id)
      @result = nil
    end
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects or /projects.json
  def create
    @project = current_user.projects.build(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to project_path(@project), notice: "Project was successfully created." }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to project_path(@project), notice: "Project was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy!

    respond_to do |format|
      format.html { redirect_to projects_path, notice: "Project was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = current_user.projects.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.expect(project: [ :name, :github_link, :description, :skills ])
    end

    def prefill_params
      params.permit(:name, :description, :skills).to_h.symbolize_keys
    end
end
