require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "fixtures are loaded" do
    assert Project.exists?(projects(:one).id)
    assert Project.exists?(projects(:two).id)
  end

  test "fixture one has expected attributes" do
    project = projects(:one)

    assert_equal "MyString", project.name
    assert_equal "MyString", project.github_link
    assert_equal "MyText", project.description
    assert_equal "MyString", project.skills
  end

  test "can create a project with all attributes" do
    assert_difference("Project.count", 1) do
      Project.create!(
        name: "Portfolio Site",
        github_link: "https://github.com/example/portfolio",
        description: "Personal portfolio web app",
        skills: "Rails,HTML,CSS"
      )
    end
  end

  test "can create a project with blank attributes" do
    assert_difference("Project.count", 1) do
      project = Project.create!(name: "", github_link: "", description: "", skills: "")
      assert_equal "", project.name
      assert_equal "", project.github_link
    end
  end

  test "can update project name" do
    project = projects(:one)
    project.update!(name: "Updated Name")

    assert_equal "Updated Name", project.reload.name
  end

  test "can update github link" do
    project = projects(:one)
    project.update!(github_link: "https://github.com/example/new-repo")

    assert_equal "https://github.com/example/new-repo", project.reload.github_link
  end

  test "can update description" do
    project = projects(:one)
    project.update!(description: "Updated description")

    assert_equal "Updated description", project.reload.description
  end

  test "can update skills" do
    project = projects(:one)
    project.update!(skills: "Ruby,SQL")

    assert_equal "Ruby,SQL", project.reload.skills
  end

  test "can destroy a project" do
    project = projects(:two)

    assert_difference("Project.count", -1) do
      project.destroy
    end
  end

  test "timestamps are present for persisted records" do
    project = Project.create!(name: "Timestamp Test")

    assert_not_nil project.created_at
    assert_not_nil project.updated_at
  end
end
