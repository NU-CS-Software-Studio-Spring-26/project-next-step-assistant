require "test_helper"

class UserTest < ActiveSupport::TestCase
  def valid_password
    "Password1!"
  end

  test "rejects email longer than 255 characters" do
    user = users(:one)
    user.email = "#{'a' * 246}@example.com"

    assert_not user.valid?
    assert_includes user.errors[:email].join, "255"
  end

  test "rejects password longer than 72 characters" do
    user = users(:one)
    user.password = "#{valid_password}#{'x' * 64}"
    user.password_confirmation = user.password

    assert_not user.valid?
    assert_includes user.errors[:password].join, "72"
  end

  test "rejects password without uppercase letter" do
    user = User.new(email: "new@example.com", password: "password1!", password_confirmation: "password1!")

    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one uppercase letter"
  end

  test "rejects password without lowercase letter" do
    user = User.new(email: "new@example.com", password: "PASSWORD1!", password_confirmation: "PASSWORD1!")

    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one lowercase letter"
  end

  test "rejects password without number" do
    user = User.new(email: "new@example.com", password: "Password!!", password_confirmation: "Password!!")

    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one number"
  end

  test "rejects password without special character" do
    user = User.new(email: "new@example.com", password: "Password11", password_confirmation: "Password11")

    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one special character"
  end

  test "accepts password meeting complexity requirements" do
    user = User.new(email: "new@example.com", password: valid_password, password_confirmation: valid_password)

    assert user.valid?
  end

  test "allows profile update without changing password" do
    user = users(:one)
    user.email = "updated@example.com"

    assert user.valid?
    assert_empty user.errors[:password]
  end

  test "validates complexity when password is changed on update" do
    user = users(:one)
    user.password = "weak"
    user.password_confirmation = "weak"

    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "from_omniauth returns existing user by provider and uid" do
    user = users(:one)
    user.update!(provider: "github", uid: "gh-123")

    auth = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "gh-123",
      info: OmniAuth::AuthHash::InfoHash.new(email: user.email)
    )

    assert_equal user, User.from_omniauth(auth)
  end

  test "from_omniauth links existing email account to github" do
    user = users(:one)
    assert_nil user.provider

    auth = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "gh-456",
      info: OmniAuth::AuthHash::InfoHash.new(email: user.email)
    )

    linked = User.from_omniauth(auth)
    assert_equal user.id, linked.id
    assert_equal "github", linked.provider
    assert_equal "gh-456", linked.uid
  end

  test "from_omniauth creates new user when email is new" do
    auth = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "gh-789",
      info: OmniAuth::AuthHash::InfoHash.new(email: "github-new@example.com")
    )

    assert_difference("User.count", 1) do
      user = User.from_omniauth(auth)
      assert user.persisted?
      assert_equal "github", user.provider
    end
  end

  test "from_omniauth errors when github does not return email" do
    auth = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "gh-no-email",
      info: OmniAuth::AuthHash::InfoHash.new(email: nil)
    )

    user = User.from_omniauth(auth)
    assert_not user.persisted?
    assert_includes user.errors[:email].join, "GitHub"
  end

  test "from_omniauth resolves private email from all_emails" do
    auth = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "gh-private-email",
      info: OmniAuth::AuthHash::InfoHash.new(email: nil),
      extra: {
        all_emails: [
          { "email" => "private@example.com", "primary" => true, "verified" => true }
        ]
      }
    )

    assert_difference("User.count", 1) do
      user = User.from_omniauth(auth)
      assert user.persisted?
      assert_equal "private@example.com", user.email
    end
  end

  test "from_omniauth links github to signed in user" do
    user = users(:one)
    auth = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "gh-signed-in",
      info: OmniAuth::AuthHash::InfoHash.new(email: "other@example.com")
    )

    linked = User.from_omniauth(auth, current_user: user)
    assert_equal user.id, linked.id
    assert_equal "github", linked.provider
    assert_equal "gh-signed-in", linked.uid
  end

  test "from_omniauth rejects github already linked to another user" do
    users(:one).update!(provider: "github", uid: "gh-taken")
    user = users(:two)

    auth = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "gh-taken",
      info: OmniAuth::AuthHash::InfoHash.new(email: user.email)
    )

    linked = User.from_omniauth(auth, current_user: user)
    assert_includes linked.errors[:base].join, "already linked"
  end

  test "github_connected? is true when provider and uid are set" do
    user = users(:one)
    user.update!(provider: "github", uid: "gh-1")

    assert user.github_connected?
  end

  test "needs_password_setup? is true for new github users" do
    generated_password = User.oauth_password
    user = User.create!(
      email: "needs-setup@example.com",
      provider: "github",
      uid: "gh-needs-setup",
      password: generated_password,
      password_confirmation: generated_password
    )

    assert user.needs_password_setup?
  end

  test "email sign up marks password as set" do
    user = User.create!(
      email: "email-signup@example.com",
      password: valid_password,
      password_confirmation: valid_password
    )

    assert_not user.needs_password_setup?
  end
end
