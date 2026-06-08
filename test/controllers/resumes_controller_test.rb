require "test_helper"

class ResumesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @resume = resumes(:one)
    @other_resume = resumes(:two)
    sign_in users(:one)
  end

  test "should get index" do
    get resumes_url
    assert_response :success
  end

  test "should show resume" do
    get resume_url(@resume)
    assert_response :success
  end

  test "show page renders resume details" do
    resume = create_resume_via_upload(name: "Show Page Resume")

    get resume_url(resume)

    assert_response :success
    assert_select "h1", text: "Show Page Resume"
    assert_select "dd", text: "resume.pdf"
  end

  test "show page includes download link when file is attached" do
    resume = create_resume_via_upload(name: "Download Link Resume")

    get resume_url(resume)

    assert_response :success
    assert_select "a.btn-primary", text: "Download Resume" do |links|
      assert_equal download_resume_path(resume), links.first[:href]
    end
  end

  test "download sends attached pdf" do
    resume = create_resume_via_upload(name: "Downloadable Resume")

    get download_resume_url(resume)

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_match(/attachment/, response.headers["Content-Disposition"])
    assert response.body.start_with?("%PDF")
  end

  test "cannot download another users resume" do
    get download_resume_url(@other_resume)
    assert_response :not_found
  end

  test "should get edit" do
    get edit_resume_url(@resume)
    assert_response :success
  end

  test "cannot show another users resume" do
    get resume_url(@other_resume)
    assert_response :not_found
  end

  test "cannot edit another users resume" do
    get edit_resume_url(@other_resume)
    assert_response :not_found
  end

  test "cannot update another users resume" do
    patch resume_url(@other_resume), params: { resume: { name: "Hijacked" } }
    assert_response :not_found
    assert_equal "Test Resume Two", @other_resume.reload.name
  end

  test "cannot destroy another users resume" do
    assert_no_difference("Resume.count") do
      delete resume_url(@other_resume)
    end
    assert_response :not_found
  end

  test "destroys unused resume" do
    resume = create_resume_via_upload(name: "Unused Resume")

    assert_difference("Resume.count", -1) do
      delete resume_url(resume)
    end

    assert_redirected_to resumes_path
    assert_equal "Resume deleted.", flash[:notice]
    assert_nil Resume.find_by(id: resume.id)
  end

  test "blocks delete when resume is attached to a job" do
    resume = create_resume_via_upload(name: "Attached Resume")
    jobs(:two).update!(resume: resume)

    assert_no_difference("Resume.count") do
      delete resume_url(resume)
    end

    assert_redirected_to resumes_path
    assert_match(/used by jobs/i, flash[:alert])
    assert Resume.exists?(resume.id)
  end

  private

  def pdf_upload
    Rack::Test::UploadedFile.new(
      StringIO.new("%PDF-1.4\n%EOF"),
      "application/pdf",
      original_filename: "resume.pdf"
    )
  end

  def create_resume_via_upload(name:)
    assert_difference("Resume.count", 1) do
      post resumes_url, params: { resume: { name: name, file: pdf_upload } }
    end

    assert_redirected_to resumes_path
    Resume.order(:id).last
  end
end
