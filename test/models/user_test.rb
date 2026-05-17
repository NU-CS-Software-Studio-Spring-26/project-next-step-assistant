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
end
