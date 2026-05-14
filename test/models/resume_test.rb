require "test_helper"

class ResumeTest < ActiveSupport::TestCase
  test "rejects name longer than 200 characters" do
    resume = Resume.new(name: "x" * 201)
    resume.validate

    assert_not resume.valid?
    assert_includes resume.errors[:name].join, "200"
  end
end
