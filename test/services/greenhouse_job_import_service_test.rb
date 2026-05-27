require "test_helper"

class GreenhouseJobImportServiceTest < ActiveSupport::TestCase
  BOARDS_URL = "https://boards.greenhouse.io/openai/jobs/123456"
  JOB_BOARDS_URL = "https://job-boards.greenhouse.io/greenhouse/jobs/7724285?gh_jid=7724285"

  def sample_job_payload(listing_url = BOARDS_URL)
    {
      "title" => "Software Engineer",
      "content" => "<p>Build APIs with Ruby.</p>",
      "location" => { "name" => "San Francisco, CA" },
      "absolute_url" => listing_url,
      "company_name" => "Acme Corp"
    }
  end

  test "imports job attributes from boards.greenhouse.io url" do
    http = ->(board, job_id) {
      assert_equal "openai", board
      assert_equal "123456", job_id
      sample_job_payload(BOARDS_URL)
    }
    result = GreenhouseJobImportService.new(BOARDS_URL, http: http).call

    assert_equal :ready, result.state
    assert_equal "Software Engineer", result.attributes["title"]
    assert_equal "Acme Corp", result.attributes["organization_name"]
    assert_equal "Company website", result.attributes["source"]
    assert_equal 30.days.from_now.to_date, result.attributes["deadline"]
    assert_includes result.attributes["description"], "Location: San Francisco, CA"
    assert_includes result.attributes["description"], BOARDS_URL
    assert_includes result.attributes["description"], "Build APIs with Ruby."
  end

  test "imports job attributes from job-boards.greenhouse.io url" do
    http = ->(board, job_id) {
      assert_equal "greenhouse", board
      assert_equal "7724285", job_id
      sample_job_payload(JOB_BOARDS_URL)
    }
    result = GreenhouseJobImportService.new(JOB_BOARDS_URL, http: http).call

    assert_equal :ready, result.state
    assert_equal "Software Engineer", result.attributes["title"]
    assert_includes result.attributes["description"], JOB_BOARDS_URL
  end

  test "rejects non greenhouse host" do
    result = GreenhouseJobImportService.new("https://example.com/jobs/1", http: http_stub).call

    assert_equal :invalid_url, result.state
    assert_match(/boards\.greenhouse\.io|job-boards\.greenhouse\.io/, result.message)
  end

  test "rejects malformed greenhouse url without job id" do
    result = GreenhouseJobImportService.new("https://boards.greenhouse.io/acme/jobs/", http: http_stub).call

    assert_equal :invalid_url, result.state
  end

  test "rejects wrong greenhouse subdomain host" do
    result = GreenhouseJobImportService.new("https://jobs.greenhouse.io/acme/jobs/123", http: http_stub).call

    assert_equal :invalid_url, result.state
  end

  test "returns not found when api payload is blank" do
    http = ->(_board, _id) { nil }
    result = GreenhouseJobImportService.new(BOARDS_URL, http: http).call

    assert_equal :not_found, result.state
    assert_equal "Unable to import Greenhouse listing.", result.message
  end

  test "returns error when api raises" do
    http = ->(_board, _id) { raise Timeout::Error, "timed out" }
    result = GreenhouseJobImportService.new(BOARDS_URL, http: http).call

    assert_equal :error, result.state
    assert_equal "Unable to import Greenhouse listing.", result.message
  end

  test "humanizes board token when company name missing" do
    payload = sample_job_payload.except("company_name")
    http = ->(_board, _id) { payload }
    result = GreenhouseJobImportService.new(BOARDS_URL, http: http).call

    assert_equal :ready, result.state
    assert_equal "Openai", result.attributes["organization_name"]
  end

  test "truncates very long imported descriptions to job max length" do
    payload = sample_job_payload.merge(
      "content" => "<p>#{'A' * (Job::DESCRIPTION_MAX_LENGTH + 1000)}</p>"
    )
    http = ->(_board, _id) { payload }

    result = GreenhouseJobImportService.new(BOARDS_URL, http: http).call

    assert_equal :ready, result.state
    assert_operator result.attributes["description"].length, :<=, Job::DESCRIPTION_MAX_LENGTH
  end

  test "uses deadline from payload when present" do
    payload = sample_job_payload.merge("deadline" => "2026-09-15")
    http = ->(_board, _id) { payload }

    result = GreenhouseJobImportService.new(BOARDS_URL, http: http).call

    assert_equal :ready, result.state
    assert_equal Date.new(2026, 9, 15), result.attributes["deadline"]
  end

  test "decodes entities and strips html tags from imported description" do
    payload = sample_job_payload.merge(
      "content" => "&lt;div&gt;Our mission at Greenhouse is &amp; always has been.&lt;/div&gt;<p>Build <strong>safe</strong> software.</p>"
    )
    http = ->(_board, _id) { payload }

    result = GreenhouseJobImportService.new(BOARDS_URL, http: http).call
    description = result.attributes["description"]

    assert_equal :ready, result.state
    assert_includes description, "Our mission at Greenhouse is & always has been."
    assert_includes description, "Build safe software."
    assert_not_includes description, "&lt;div&gt;"
    assert_not_includes description, "<div>"
    assert_not_includes description, "<strong>"
  end

  test "does not infer deadline from random description dates" do
    payload = sample_job_payload.merge(
      "content" => "<p>Compensation review date: 06/26/26. This is not an application deadline.</p>",
      "deadline" => nil,
      "metadata" => { "deadline" => "2026-06-26" }
    )
    http = ->(_board, _id) { payload }

    result = GreenhouseJobImportService.new(BOARDS_URL, http: http).call

    assert_equal :ready, result.state
    assert_equal 30.days.from_now.to_date, result.attributes["deadline"]
  end

  private

  def http_stub
    ->(_board, _id) { sample_job_payload }
  end
end
