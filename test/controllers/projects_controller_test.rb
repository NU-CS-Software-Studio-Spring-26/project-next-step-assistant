require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    sign_in users(:one)
  end

  test "should get index" do
    get projects_url
    assert_response :success
  end

  test "should get new" do
    get new_project_url
    assert_response :success
  end

  test "should create project" do
    assert_difference("Project.count") do
      post projects_url, params: {
        project: {
          description: "New test project description",
          github_link: "https://github.com/example/new-project",
          name: "Unique Test Project",
          skills: "Ruby, Rails"
        }
      }
    end

    assert_redirected_to project_url(Project.last)
  end

  test "should show project" do
    get project_url(@project)
    assert_response :success
  end

  test "should get edit" do
    get edit_project_url(@project)
    assert_response :success
  end

  test "should update project" do
    patch project_url(@project), params: { project: { description: @project.description, github_link: @project.github_link, name: @project.name, skills: @project.skills } }
    assert_redirected_to project_url(@project)
  end

  test "should destroy project" do
    assert_difference("Project.count", -1) do
      delete project_url(@project)
    end

    assert_redirected_to projects_url
  end

  test "cannot show another users project" do
    get project_url(projects(:other_users))
    assert_response :not_found
  end

  test "cannot edit another users project" do
    get edit_project_url(projects(:other_users))
    assert_response :not_found
  end

  test "cannot update another users project" do
    other = projects(:other_users)
    patch project_url(other), params: { project: { name: "Hijacked" } }
    assert_response :not_found
    assert_equal "Other User Private Project", other.reload.name
  end

  test "cannot destroy another users project" do
    assert_no_difference("Project.count") do
      delete project_url(projects(:other_users))
    end
    assert_response :not_found
  end
end
