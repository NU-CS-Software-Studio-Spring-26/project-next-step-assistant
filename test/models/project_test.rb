require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "is valid with just a name" do
    assert Project.new(name: "My Project", user: users(:one)).valid?
  end

  test "requires name" do
    project = Project.new(name: nil, user: users(:one))
    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"
  end

  test "rejects name longer than 200 characters" do
    project = Project.new(name: "x" * 201, user: users(:one))
    assert_not project.valid?
  end

  test "rejects description longer than 5000 characters" do
    project = Project.new(name: "Ok", description: "x" * 5_001, user: users(:one))
    assert_not project.valid?
  end

  test "rejects skills longer than 255 characters" do
    project = Project.new(name: "Ok", skills: "x" * 256, user: users(:one))
    assert_not project.valid?
  end

  test "rejects github_link longer than 2048 characters" do
    project = Project.new(name: "Ok", github_link: "https://example.com/#{'a' * 2_040}", user: users(:one))
    assert_not project.valid?
  end

  test "allows blank github_link" do
    assert Project.new(name: "Ok", github_link: "", user: users(:one)).valid?
    assert Project.new(name: "Ok", github_link: nil, user: users(:one)).valid?
  end

  test "rejects malformed github_link" do
    project = Project.new(name: "Ok", github_link: "not a url", user: users(:one))
    assert_not project.valid?
    assert_includes project.errors[:github_link].join, "invalid"
  end

  test "accepts valid http and https github_link" do
    assert Project.new(name: "Ok", github_link: "https://github.com/example/repo", user: users(:one)).valid?
    assert Project.new(name: "Ok", github_link: "http://example.com", user: users(:one)).valid?
  end
end
