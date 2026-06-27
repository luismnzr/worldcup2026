require "test_helper"

class FootballDataClientTest < ActiveSupport::TestCase
  test "not configured when neither ENV nor setting is present" do
    StudioSetting.set("football_data_api_token", "")
    with_env(nil) do
      assert_nil FootballDataClient.resolve_token
      assert_not FootballDataClient.new.configured?
    end
  end

  test "falls back to the Settings value when ENV is absent" do
    StudioSetting.set("football_data_api_token", "from_settings")
    with_env(nil) do
      assert_equal "from_settings", FootballDataClient.resolve_token
      assert FootballDataClient.new.configured?
    end
  end

  test "ENV takes precedence over Settings" do
    StudioSetting.set("football_data_api_token", "from_settings")
    with_env("from_env") do
      assert_equal "from_env", FootballDataClient.resolve_token
    end
  end

  private

  def with_env(value)
    previous = ENV["FOOTBALL_DATA_API_TOKEN"]
    value.nil? ? ENV.delete("FOOTBALL_DATA_API_TOKEN") : ENV["FOOTBALL_DATA_API_TOKEN"] = value
    yield
  ensure
    previous.nil? ? ENV.delete("FOOTBALL_DATA_API_TOKEN") : ENV["FOOTBALL_DATA_API_TOKEN"] = previous
  end
end
