require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "rejects email longer than 255 characters" do
    user = users(:one)
    user.email = "#{'a' * 246}@example.com"

    assert_not user.valid?
    assert_includes user.errors[:email].join, "255"
  end

  test "rejects password longer than 72 characters" do
    user = users(:one)
    user.password = "x" * 73
    user.password_confirmation = "x" * 73

    assert_not user.valid?
    assert_includes user.errors[:password].join, "72"
  end
end
