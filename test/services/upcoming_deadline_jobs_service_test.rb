require "test_helper"

class UpcomingDeadlineJobsServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @as_of = Date.new(2026, 4, 15)
  end

  test "includes job with deadline in window" do
    job = @user.jobs.create!(
      title: "Upcoming Window Job",
      organization_name: "Corp",
      deadline: @as_of + 3.days,
      status: :applied
    )

    results = UpcomingDeadlineJobsService.new(@user, as_of: @as_of).call

    assert_includes results, job
  end

  test "excludes job past window" do
    job = @user.jobs.create!(
      title: "Past Window Job",
      organization_name: "Corp",
      deadline: @as_of + 4.days,
      status: :applied
    )

    results = UpcomingDeadlineJobsService.new(@user, as_of: @as_of).call

    assert_not_includes results, job
  end

  test "excludes job before today" do
    job = @user.jobs.create!(
      title: "Past Deadline Job",
      organization_name: "Corp",
      deadline: @as_of - 1.day,
      status: :applied
    )

    results = UpcomingDeadlineJobsService.new(@user, as_of: @as_of).call

    assert_not_includes results, job
  end

  test "excludes job with nil deadline" do
    job = @user.jobs.create!(
      title: "No Deadline Job",
      organization_name: "Corp",
      deadline: nil,
      status: :accepted
    )

    results = UpcomingDeadlineJobsService.new(@user, as_of: @as_of).call

    assert_not_includes results, job
  end

  test "excludes terminal status in window" do
    job = @user.jobs.create!(
      title: "Rejected In Window",
      organization_name: "Corp",
      deadline: @as_of + 2.days,
      status: :rejected
    )

    results = UpcomingDeadlineJobsService.new(@user, as_of: @as_of).call

    assert_not_includes results, job
  end

  test "scopes to user" do
    other_job = jobs(:other_users)
    other_job.update!(deadline: @as_of + 2.days)

    results = UpcomingDeadlineJobsService.new(@user, as_of: @as_of).call

    assert_not_includes results, other_job
  end

  test "orders by deadline ascending" do
    later = @user.jobs.create!(
      title: "Later Deadline",
      organization_name: "Corp",
      deadline: @as_of + 3.days,
      status: :saved
    )
    sooner = @user.jobs.create!(
      title: "Sooner Deadline",
      organization_name: "Corp",
      deadline: @as_of + 1.day,
      status: :saved
    )

    results = UpcomingDeadlineJobsService.new(@user, as_of: @as_of).call.to_a
    scoped = results.select { |j| [ later.id, sooner.id ].include?(j.id) }

    assert_equal [ sooner, later ], scoped
  end
end
