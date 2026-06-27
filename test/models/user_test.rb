require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = build(:user)
    assert user.valid?
  end

  test "requires first_name" do
    user = build(:user, first_name: nil)
    assert_not user.valid?
  end

  test "requires last_name" do
    user = build(:user, last_name: nil)
    assert_not user.valid?
  end

  test "requires unique email" do
    create(:user, email: "test@example.com")
    user = build(:user, email: "test@example.com")
    assert_not user.valid?
  end

  test "full_name returns combined name" do
    user = build(:user, first_name: "Jane", last_name: "Doe")
    assert_equal "Jane Doe", user.full_name
  end

  test "role enum works" do
    assert build(:user, role: :student).student?
    assert build(:user, role: :admin).admin?
  end

  test "has_active_subscription? with active subscription" do
    user = create(:user)
    create(:user_subscription, user: user, status: "active", current_period_end: 1.month.from_now)
    assert user.has_active_subscription?
  end

  test "has_active_subscription? without subscription" do
    user = create(:user)
    assert_not user.has_active_subscription?
  end
end
