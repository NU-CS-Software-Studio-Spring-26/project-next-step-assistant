require "test_helper"

class GithubOauthEmailResolverTest < ActiveSupport::TestCase
  test "uses info email when present" do
    auth = OmniAuth::AuthHash.new(
      info: OmniAuth::AuthHash::InfoHash.new(email: "Primary@Example.com")
    )

    assert_equal "primary@example.com", GithubOauthEmailResolver.call(auth)
  end

  test "falls back to primary verified email in all_emails" do
    auth = OmniAuth::AuthHash.new(
      info: OmniAuth::AuthHash::InfoHash.new(email: nil),
      extra: {
        all_emails: [
          { "email" => "other@example.com", "primary" => false, "verified" => true },
          { "email" => "main@example.com", "primary" => true, "verified" => true }
        ]
      }
    )

    assert_equal "main@example.com", GithubOauthEmailResolver.call(auth)
  end

  test "falls back to first verified email when no primary" do
    auth = OmniAuth::AuthHash.new(
      info: OmniAuth::AuthHash::InfoHash.new(email: nil),
      extra: {
        all_emails: [
          { "email" => "first@example.com", "primary" => false, "verified" => true },
          { "email" => "second@example.com", "primary" => false, "verified" => true }
        ]
      }
    )

    assert_equal "first@example.com", GithubOauthEmailResolver.call(auth)
  end

  test "returns nil when no email is available" do
    auth = OmniAuth::AuthHash.new(
      info: OmniAuth::AuthHash::InfoHash.new(email: nil),
      extra: { all_emails: [] }
    )

    assert_nil GithubOauthEmailResolver.call(auth)
  end
end
