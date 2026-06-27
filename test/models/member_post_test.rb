require "test_helper"

class MemberPostTest < ActiveSupport::TestCase
  test "valid post" do
    assert build(:member_post).valid?
  end

  test "requires title" do
    assert_not build(:member_post, title: nil).valid?
  end

  test "auto-generates slug from title" do
    post = MemberPost.create!(title: "Hola Mundo!", body: "test")
    assert_equal "hola-mundo", post.slug
  end

  test "auto-generated slug is unique" do
    create(:member_post, title: "Mismo Titulo", slug: "mismo-titulo")
    second = MemberPost.create!(title: "Mismo Titulo", body: "test")
    assert_equal "mismo-titulo-2", second.slug
  end

  test "published scope only returns posts with past published_at" do
    create(:member_post, :draft)
    create(:member_post, published_at: 1.day.from_now)
    visible = create(:member_post, published_at: 1.day.ago)

    assert_equal [ visible ], MemberPost.published.to_a
  end
end
