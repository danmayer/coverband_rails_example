require "test_helper"

class DemoControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get demo_url
    assert_response :success
    assert_select "h1", text: /Welcome to the Coverband demo/i
  end

  test "should get configuration page" do
    get demo_configuration_url
    assert_response :success
    assert_select "h1", text: "Coverband Configuration"
  end

  test "configuration page should show current settings" do
    get demo_configuration_url
    assert_response :success

    # Should display current configuration values
    assert_select "table.config-table" do
      assert_select "td", text: "track_views"
      assert_select "td", text: "track_translations"
      assert_select "td", text: "track_routes"
    end
  end

  test "configuration page should show environment variables" do
    get demo_configuration_url
    assert_response :success

    # Should list environment variables
    assert_select "code", text: "COVERBAND_TRACK_VIEWS"
    assert_select "code", text: "COVERBAND_TRACK_TRANSLATIONS"
    assert_select "code", text: "COVERBAND_TRACK_ROUTES"
  end

  test "should get benchmarks page" do
    get demo_benchmarks_url
    assert_response :success
    assert_select "h1", text: "Performance Benchmarks"
  end

  test "benchmarks page should show rake task examples" do
    get demo_benchmarks_url
    assert_response :success

    # Should show benchmark commands
    assert_select "code", text: /coverband_benchmark/
    assert_select "code", text: /generate_files/
  end

  test "should get profiling page" do
    get demo_profiling_url
    assert_response :success
    assert_select "h1", text: "Memory Profiling & Stats"
  end

  test "profiling page should display memory statistics" do
    get demo_profiling_url
    assert_response :success

    # Should display memory stats
    assert_select ".stat-card" do
      assert_select ".stat-value"
      assert_select ".stat-label"
    end
  end
end
