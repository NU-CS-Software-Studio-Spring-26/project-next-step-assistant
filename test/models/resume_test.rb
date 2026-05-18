require "test_helper"
require "stringio"

class ResumeTest < ActiveSupport::TestCase
  test "rejects name longer than 200 characters" do
    resume = Resume.new(name: "x" * 201, user: users(:one))
    resume.validate

    assert_not resume.valid?
    assert_includes resume.errors[:name].join, "200"
  end

  test "rejects files larger than 5 MB" do
    resume = Resume.new(name: "Software Resume", user: users(:one))
    resume.file.attach(
      io: StringIO.new("x" * (Resume::FILE_MAX_SIZE + 1)),
      filename: "resume.pdf",
      content_type: "application/pdf"
    )

    assert_not resume.valid?
    assert_includes resume.errors[:file].join, "5 MB or smaller"
  end

  test "accepts valid pdf file" do
    resume = Resume.new(name: "Software Resume", user: users(:one))
    resume.file.attach(
      io: StringIO.new("%PDF-1.4\n%EOF"),
      filename: "resume.pdf",
      content_type: "application/pdf"
    )

    resume.validate
    assert_empty resume.errors[:file]
  end

  test "rejects non-pdf content with pdf extension" do
    resume = Resume.new(name: "Software Resume", user: users(:one))
    resume.file.attach(
      io: StringIO.new("not a pdf file"),
      filename: "resume.pdf",
      content_type: "application/pdf"
    )

    assert_not resume.valid?
    assert_includes resume.errors[:file].join, "PDF"
  end

  test "rejects pdf magic bytes with non-pdf extension" do
    resume = Resume.new(name: "Software Resume", user: users(:one))
    resume.file.attach(
      io: StringIO.new("%PDF-1.4\n"),
      filename: "resume.txt",
      content_type: "application/pdf"
    )

    assert_not resume.valid?
    assert_includes resume.errors[:file].join, "PDF"
  end

  test "rejects non-pdf content type and magic bytes" do
    resume = Resume.new(name: "Software Resume", user: users(:one))
    resume.file.attach(
      io: StringIO.new("plain text content"),
      filename: "resume.pdf",
      content_type: "text/plain"
    )

    assert_not resume.valid?
    assert_includes resume.errors[:file].join, "PDF"
  end
end
