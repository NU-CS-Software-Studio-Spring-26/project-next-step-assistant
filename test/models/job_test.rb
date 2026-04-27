require "test_helper"

class JobTest < ActiveSupport::TestCase
  def valid_attrs(overrides = {})
    {
      title: "Software Engineer Intern",
      organization_name: "Acme Corp",
      status: "applied"
    }.merge(overrides)
  end

  test "is valid with required attributes" do
    assert Job.new(valid_attrs).valid?
  end

  test "requires title" do
    job = Job.new(valid_attrs(title: nil))
    assert_not job.valid?
    assert_includes job.errors[:title], "can't be blank"
  end

  test "requires organization_name" do
    job = Job.new(valid_attrs(organization_name: nil))
    assert_not job.valid?
    assert_includes job.errors[:organization_name], "can't be blank"
  end

  test "rejects title longer than 200 characters" do
    job = Job.new(valid_attrs(title: "x" * 201))
    assert_not job.valid?
    assert_includes job.errors[:title].join, "200"
  end

  test "rejects organization_name longer than 200 characters" do
    job = Job.new(valid_attrs(organization_name: "x" * 201))
    assert_not job.valid?
  end

  test "rejects description longer than 5000 characters" do
    job = Job.new(valid_attrs(description: "x" * 5_001))
    assert_not job.valid?
  end

  test "defaults status to saved" do
    assert_equal "saved", Job.new.status
  end

  test "raises on invalid status assignment" do
    assert_raises(ArgumentError) { Job.new(status: "bogus") }
  end

  test "applied scope returns only applied jobs" do
    Job.delete_all
    applied = Job.create!(valid_attrs(status: "applied"))
    Job.create!(valid_attrs(title: "Other", status: "saved"))
    assert_equal [ applied ], Job.applied.to_a
  end

  test "predicate methods reflect status" do
    job = Job.new(valid_attrs(status: "interviewing"))
    assert job.interviewing?
    assert_not job.applied?
  end
end
