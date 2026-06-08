require "test_helper"

class JobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @job = jobs(:one)
    sign_in users(:one)
  end

  test "should get index" do
    get jobs_url
    assert_response :success
  end

  test "should get new" do
    get new_job_url
    assert_response :success
  end

  test "should create job" do
    assert_difference("Job.count") do
      post jobs_url, params: {
        job: {
          deadline: Date.today + 7.days,
          description: "New test job description",
          organization_name: "New Test Company",
          start_date: Date.today,
          status: "saved",
          title: "Unique Test Job"
        }
      }
    end

    assert_redirected_to job_url(Job.last)
  end

  test "should show job" do
    get job_url(@job)
    assert_response :success
  end

  test "should get edit" do
    get edit_job_url(@job)
    assert_response :success
  end

  test "should update job" do
    patch job_url(@job), params: { job: { deadline: @job.deadline, description: @job.description, organization_name: @job.organization_name, start_date: @job.start_date, status: @job.status, title: @job.title } }
    assert_redirected_to job_url(@job)
  end

  test "should destroy job" do
    assert_difference("Job.count", -1) do
      delete job_url(@job)
    end

    assert_redirected_to jobs_url
  end

  test "cannot show another users job" do
    get job_url(jobs(:other_users))
    assert_response :not_found
  end

  test "cannot edit another users job" do
    get edit_job_url(jobs(:other_users))
    assert_response :not_found
  end

  test "cannot update another users job" do
    other = jobs(:other_users)
    patch job_url(other), params: { job: { title: "Hijacked" } }
    assert_response :not_found
    assert_equal "Other User Private Job", other.reload.title
  end

  test "cannot destroy another users job" do
    assert_no_difference("Job.count") do
      delete job_url(jobs(:other_users))
    end
    assert_response :not_found
  end

  test "create job ignores invalid status param" do
    assert_difference("Job.count", 1) do
      post jobs_url, params: {
        job: {
          deadline: Date.today + 7.days,
          organization_name: "Status Test Co",
          title: "Status Filter Job",
          status: "not_a_real_status"
        }
      }
    end

    assert_equal "saved", Job.last.status
  end

  test "requires authentication" do
    sign_out :user
    get jobs_url
    assert_redirected_to new_user_session_path
  end

  test "filters jobs by normalized status param" do
    get jobs_url, params: { status: "applied" }
    assert_response :success
    assert_includes response.body, jobs(:one).title
    assert_not_includes response.body, jobs(:two).title
  end

  test "accepts titleized status param from legacy links" do
    get jobs_url, params: { status: "Applied" }
    assert_response :success
    assert_includes response.body, jobs(:one).title
    assert_not_includes response.body, jobs(:two).title
  end

  test "ignores invalid status filter" do
    get jobs_url, params: { status: "not_a_status" }
    assert_response :success
    assert_includes response.body, jobs(:one).title
    assert_includes response.body, jobs(:two).title
  end

  test "search filters jobs by title" do
    get jobs_url, params: { query: "Intern" }
    assert_response :success
    assert_includes response.body, "Software Engineer Intern"
    assert_not_includes response.body, jobs(:two).title
  end

  test "responds to turbo frame request for jobs list" do
    get jobs_url, headers: { "Turbo-Frame" => "jobs_list" }
    assert_response :success
    assert_select "turbo-frame#jobs_list"
  end

  test "show renders match assistant section" do
    get job_url(@job)
    assert_response :success
    assert_select "#job-match-assistant-heading"
  end

  test "paginates jobs index" do
    user = users(:one)
    21.times do |i|
      user.jobs.create!(
        title: "Pagy Test Job #{i}",
        organization_name: "Org #{i}",
        deadline: Date.current + i.days,
        status: :saved
      )
    end

    get jobs_url, params: { page: 2 }
    assert_response :success
    assert_match(/Pagy Test Job/, response.body)
  end

  test "greenhouse import end to end creates job from imported data" do
    default_deadline = 30.days.from_now.to_date
    attrs = {
      "title" => "Greenhouse E2E Role",
      "organization_name" => "Imported Corp",
      "description" => "Location: Remote\n\nApply:\nhttps://boards.greenhouse.io/acme/jobs/123",
      "source" => "Company website",
      "deadline" => default_deadline
    }
    fake_importer = build_fake_greenhouse_importer(
      GreenhouseJobImportService::Result.new(state: :ready, attributes: attrs, message: nil)
    )

    with_greenhouse_importer_stub(fake_importer) do
      post import_greenhouse_jobs_url, params: {
        greenhouse_url: "https://boards.greenhouse.io/acme/jobs/123456"
      }
    end

    assert_redirected_to new_job_path(job: attrs, greenhouse_imported: "1")
    follow_redirect!

    assert_response :success
    assert_match(/Imported from Greenhouse/, response.body)
    assert_select "input[name='job[title]'][value=?]", attrs["title"]
    assert_select "input[name='job[organization_name]'][value=?]", attrs["organization_name"]

    assert_difference("Job.count", 1) do
      post jobs_url, params: {
        job: {
          title: attrs["title"],
          organization_name: attrs["organization_name"],
          description: attrs["description"],
          source: attrs["source"],
          deadline: attrs["deadline"],
          status: "saved"
        }
      }
    end

    created = Job.last
    assert_redirected_to job_url(created)
    assert_equal attrs["title"], created.title
    assert_equal attrs["organization_name"], created.organization_name
    assert_equal attrs["description"], created.description
    assert_equal attrs["source"], created.source
    assert_equal attrs["deadline"], created.deadline
    assert_equal users(:one), created.user
  end

  test "import_greenhouse redirects to new job with prefilled params" do
    default_deadline = 30.days.from_now.to_date
    attrs = {
      "title" => "Imported Role",
      "organization_name" => "Acme Corp",
      "description" => "Location: Remote\n\nApply:\nhttps://boards.greenhouse.io/acme/jobs/123",
      "source" => "Company website",
      "deadline" => default_deadline
    }
    fake_importer = build_fake_greenhouse_importer(
      GreenhouseJobImportService::Result.new(state: :ready, attributes: attrs, message: nil)
    )

    with_greenhouse_importer_stub(fake_importer) do
      assert_no_difference("Job.count") do
        post import_greenhouse_jobs_url, params: {
          greenhouse_url: "https://boards.greenhouse.io/acme/jobs/123456"
        }
      end
    end

    assert_redirected_to new_job_path(job: attrs, greenhouse_imported: "1")
    assert_equal "Review imported job details.", flash[:notice]
  end

  test "import_greenhouse redirects to import with alert on failure" do
    fake_importer = build_fake_greenhouse_importer(
      GreenhouseJobImportService::Result.new(
        state: :invalid_url,
        attributes: {},
        message: "Enter a valid Greenhouse job URL"
      )
    )

    with_greenhouse_importer_stub(fake_importer) do
      post import_greenhouse_jobs_url, params: { greenhouse_url: "https://evil.example/jobs/1" }
    end

    assert_redirected_to import_jobs_path
    assert_match(/valid Greenhouse/i, flash[:alert])
  end

  test "import page shows greenhouse section without openai" do
    with_env("OPENAI_API_KEY" => nil) do
      get import_jobs_path
      assert_response :success
      assert_match(/Import from Greenhouse/i, response.body)
      assert_match(/greenhouse_url/i, response.body)
    end
  end

  test "new job page shows greenhouse import notice only when flagged" do
    get new_job_url, params: { greenhouse_imported: "1" }
    assert_response :success
    assert_match(/Imported from Greenhouse\. Please review the details before saving\./, response.body)

    get new_job_url
    assert_response :success
    assert_no_match(/Imported from Greenhouse\. Please review the details before saving\./, response.body)
  end

  test "create job rejects another users resume_id" do
    other_resume = resumes(:two)
    assert_difference("Job.count", 1) do
      post jobs_url, params: {
        job: {
          deadline: Date.today + 7.days,
          organization_name: "Resume Scope Co",
          title: "Resume Scope Job",
          resume_id: other_resume.id
        }
      }
    end

    assert_nil Job.last.resume_id
  end

  private

  def build_fake_greenhouse_importer(result)
    Class.new do
      define_method(:initialize) { |*_args, **_kwargs| }
      define_method(:call) { result }
    end.new
  end

  def with_greenhouse_importer_stub(fake_importer)
    singleton = GreenhouseJobImportService.singleton_class
    singleton.alias_method(:greenhouse_import_new_without_stub, :new)
    singleton.define_method(:new) { |*_args, **_kwargs| fake_importer }
    yield
  ensure
    singleton.alias_method(:new, :greenhouse_import_new_without_stub)
    singleton.remove_method(:greenhouse_import_new_without_stub)
  end

  def with_env(vars)
    previous = vars.keys.index_with { |key| ENV[key] }
    vars.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    yield
  ensure
    previous.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
