require "test_helper"
require "stringio"

class ResumeTest < ActiveSupport::TestCase
  test "rejects name longer than 200 characters" do
    resume = Resume.new(name: "x" * 201)
    resume.validate

    assert_not resume.valid?
    assert_includes resume.errors[:name].join, "200"
  end

  test "rejects files larger than 5 MB" do
    resume = Resume.new(name: "Software Resume")
    resume.file.attach(
      io: StringIO.new("x" * (Resume::FILE_MAX_SIZE + 1)),
      filename: "resume.pdf",
      content_type: "application/pdf"
    )

    assert_not resume.valid?
    assert_includes resume.errors[:file].join, "5 MB or smaller"
  end
end
