require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "github_oauth_configured? is false without env vars" do
    with_env("GITHUB_CLIENT_ID" => nil, "GITHUB_CLIENT_SECRET" => nil) do
      assert_not github_oauth_configured?
    end
  end

  test "github_oauth_configured? is true when both env vars set" do
    with_env("GITHUB_CLIENT_ID" => "test-id", "GITHUB_CLIENT_SECRET" => "test-secret") do
      assert github_oauth_configured?
    end
  end

  private

  def with_env(vars)
    previous = vars.keys.index_with { |key| ENV[key] }
    vars.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    yield
  ensure
    previous.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
