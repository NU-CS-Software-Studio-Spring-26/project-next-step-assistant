require "test_helper"

class JobTest < ActiveSupport::TestCase
  test "fixtures are loaded" do
    assert Job.exists?(jobs(:one).id)
    assert Job.exists?(jobs(:two).id)
  end

  test "fixture one has expected attributes" do
    job = jobs(:one)

    assert_equal "MyString", job.title
    assert_equal "MyString", job.organization_name
    assert_equal "MyText", job.description
    assert_equal "MyString", job.status
  end

  test "can create a job with all attributes" do
    assert_difference("Job.count", 1) do
      Job.create!(
        title: "Backend Engineer",
        organization_name: "Acme Corp",
        deadline: Date.new(2026, 5, 15),
        start_date: Date.new(2026, 6, 1),
        description: "Build and maintain APIs",
        status: "Applied"
      )
    end
  end

  test "can create a job with nil optional attributes" do
    assert_difference("Job.count", 1) do
      job = Job.create!(title: nil, organization_name: nil, deadline: nil, start_date: nil, description: nil, status: nil)
      assert_nil job.title
      assert_nil job.deadline
    end
  end

  test "can update title" do
    job = jobs(:one)
    job.update!(title: "Senior Engineer")

    assert_equal "Senior Engineer", job.reload.title
  end

  test "can update organization name" do
    job = jobs(:one)
    job.update!(organization_name: "New Org")

    assert_equal "New Org", job.reload.organization_name
  end

  test "can update status" do
    job = jobs(:one)
    job.update!(status: "Interview")

    assert_equal "Interview", job.reload.status
  end

  test "can update start and deadline dates" do
    job = jobs(:one)
    new_start = Date.new(2026, 7, 1)
    new_deadline = Date.new(2026, 6, 20)

    job.update!(start_date: new_start, deadline: new_deadline)

    assert_equal new_start, job.reload.start_date
    assert_equal new_deadline, job.reload.deadline
  end

  test "can destroy a job" do
    job = jobs(:two)

    assert_difference("Job.count", -1) do
      job.destroy
    end
  end

  test "start date can be after deadline" do
    job = Job.create!(
      title: "Ordering Test",
      deadline: Date.new(2026, 6, 1),
      start_date: Date.new(2026, 6, 10)
    )

    assert_equal Date.new(2026, 6, 10), job.start_date
    assert_equal Date.new(2026, 6, 1), job.deadline
  end
end
