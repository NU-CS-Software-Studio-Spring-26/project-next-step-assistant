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
end
