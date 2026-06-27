require "test_helper"

class CountryFlagsTest < ActiveSupport::TestCase
  test "returns the flag for a canonical name" do
    assert_equal "🇲🇽", CountryFlags.emoji("México")
    assert_equal "🇦🇷", CountryFlags.emoji("Argentina")
  end

  test "is tolerant to accents and casing" do
    assert_equal "🇲🇽", CountryFlags.emoji("mexico")
    assert_equal "🇧🇷", CountryFlags.emoji("BRASIL")
  end

  test "resolves common aliases" do
    assert_equal "🇰🇷", CountryFlags.emoji("Corea")
    assert_equal "🇺🇸", CountryFlags.emoji("USA")
    assert_equal "🇳🇱", CountryFlags.emoji("Holanda")
    assert_equal "🇶🇦", CountryFlags.emoji("Qatar")
  end

  test "returns nil for bracket labels and blanks" do
    assert_nil CountryFlags.emoji("Ganador P74")
    assert_nil CountryFlags.emoji("2A")
    assert_nil CountryFlags.emoji(nil)
    assert_nil CountryFlags.emoji("")
  end
end
