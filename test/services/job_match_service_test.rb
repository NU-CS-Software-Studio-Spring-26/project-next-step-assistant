require "test_helper"

class JobMatchServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @projects = @user.projects
    @resumes = @user.resumes
  end

  test "returns no_job_description when job description is blank" do
    job = @user.jobs.build(
      title: "Analyst",
      organization_name: "Corp",
      deadline: Date.current + 30,
      description: ""
    )

    result = JobMatchService.new(job, projects: @projects, resumes: @resumes).call

    assert_equal :no_job_description, result.state
    assert_includes result.message, "Add a job description"
  end

  test "returns no_portfolio_data when user has no projects or resumes" do
    job = @user.jobs.build(
      title: "Engineer",
      organization_name: "Corp",
      deadline: Date.current + 30,
      description: "Ruby on Rails developer with PostgreSQL experience."
    )

    result = JobMatchService.new(job, projects: [], resumes: []).call

    assert_equal :no_portfolio_data, result.state
    assert_includes result.message, "Add projects or resumes"
  end

  test "finds overlap and missing keywords with match level" do
    job = jobs(:one)
    job.description = "Seeking a Ruby on Rails engineer with PostgreSQL, REST APIs, and Docker experience."

    result = JobMatchService.new(job, projects: @projects, resumes: @resumes).call

    assert_equal :ready, result.state
    assert_includes result.overlap_keywords, "ruby"
    assert_includes result.overlap_keywords, "rails"
    assert_includes result.missing_keywords, "docker"
    assert_includes %i[high medium low], result.match_level
    assert result.job_keyword_count.positive?
    assert result.portfolio_keyword_count.positive?
  end

  test "includes resume name keywords in portfolio match" do
    job = jobs(:one)
    job.description = "Looking for a software engineer with resume library and testing skills."
    resume = resumes(:one)
    resume.update!(name: "Software Testing Resume")

    result = JobMatchService.new(job, projects: [], resumes: [ resume ]).call

    assert_equal :ready, result.state
    assert_includes result.overlap_keywords, "software"
    assert_includes result.overlap_keywords, "testing"
  end

  test "reports selected resume overlap when job has a resume" do
    job = jobs(:one)
    job.description = "Ruby developer needed for backend services."
    resume = resumes(:one)
    resume.update!(name: "Ruby Backend Resume")
    job.resume = resume

    result = JobMatchService.new(job, projects: @projects, resumes: [ resume ]).call

    assert_equal :ready, result.state
    assert_includes result.selected_resume_overlap, "ruby"
  end

  test "returns no_job_description when description is nil" do
    job = jobs(:one)
    job.description = nil

    result = JobMatchService.new(job, projects: @projects, resumes: @resumes).call

    assert_equal :no_job_description, result.state
  end

  test "deduplicates keywords and handles punctuation and casing" do
    job = @user.jobs.build(
      title: "Dev",
      organization_name: "Corp",
      deadline: Date.current + 30,
      description: "RUBY!!! ruby...  Rails???   rails"
    )
    project = @user.projects.build(
      name: "App",
      skills: "Ruby",
      description: "Rails framework"
    )

    result = JobMatchService.new(job, projects: [ project ], resumes: []).call

    assert_equal :ready, result.state
    assert_equal %w[ruby rails].sort, result.overlap_keywords.sort
    assert_equal 2, result.job_keyword_count
  end

  test "returns no_keywords when description is only stop words" do
    job = @user.jobs.build(
      title: "Role",
      organization_name: "Corp",
      deadline: Date.current + 30,
      description: "the and for with this that"
    )
    project = projects(:one)

    result = JobMatchService.new(job, projects: [ project ], resumes: []).call

    assert_equal :no_keywords, result.state
  end

  test "handles job without user when portfolio passed explicitly" do
    job = Job.new(
      title: "Role",
      organization_name: "Corp",
      deadline: Date.current + 30,
      description: "Kubernetes Docker Terraform"
    )
    project = Project.new(
      name: "Infra",
      skills: "Docker, Kubernetes",
      description: "Cloud infrastructure"
    )

    result = JobMatchService.new(job, projects: [ project ], resumes: []).call

    assert_equal :ready, result.state
    assert_includes result.overlap_keywords, "docker"
    assert_includes result.overlap_keywords, "kubernetes"
  end

  test "high match when most job keywords overlap portfolio" do
    job = @user.jobs.build(
      title: "Rails Dev",
      organization_name: "Corp",
      deadline: Date.current + 30,
      description: "Ruby Rails PostgreSQL"
    )
    project = @user.projects.build(
      name: "App",
      description: "Built with Ruby and Rails using PostgreSQL database."
    )

    result = JobMatchService.new(job, projects: [ project ], resumes: []).call

    assert_equal :ready, result.state
    assert_equal :high, result.match_level
    assert_empty result.missing_keywords
  end
end
