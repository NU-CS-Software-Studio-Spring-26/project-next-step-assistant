require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "is valid with just a name" do
    assert Project.new(name: "My Project").valid?
  end

  test "requires name" do
    project = Project.new(name: nil)
    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"
  end

  test "rejects name longer than 200 characters" do
    project = Project.new(name: "x" * 201)
    assert_not project.valid?
  end

  test "rejects description longer than 5000 characters" do
    project = Project.new(name: "Ok", description: "x" * 5_001)
    assert_not project.valid?
  end

  test "rejects skills longer than 255 characters" do
    project = Project.new(name: "Ok", skills: "x" * 256)
    assert_not project.valid?
  end

  test "rejects github_link longer than 2048 characters" do
    project = Project.new(name: "Ok", github_link: "https://example.com/#{'a' * 2_040}")
    assert_not project.valid?
  end

  test "allows blank github_link" do
    assert Project.new(name: "Ok", github_link: "").valid?
    assert Project.new(name: "Ok", github_link: nil).valid?
  end

  test "rejects malformed github_link" do
    project = Project.new(name: "Ok", github_link: "not a url")
    assert_not project.valid?
    assert_includes project.errors[:github_link].join, "invalid"
  end

  test "accepts valid http and https github_link" do
    assert Project.new(name: "Ok", github_link: "https://github.com/example/repo").valid?
    assert Project.new(name: "Ok", github_link: "http://example.com").valid?
  end
end
