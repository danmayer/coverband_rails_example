require "test_helper"

# This test demonstrates how to configure Coverband and verify configuration settings.
# These tests serve as living documentation for Coverband configuration options.
class Coverband::ConfigurationTest < ActiveSupport::TestCase
  # Test: Verifying basic Coverband configuration
  # This shows how to access and check Coverband's configuration
  test "coverband should be configured and accessible" do
    assert Coverband.configuration, "Coverband should be configured"
    assert Coverband.configuration.respond_to?(:store), "Coverband should have a store configured"
  end

  # Test: Checking the storage backend
  # Demonstrates how to verify which storage adapter is being used
  test "should have a redis store configured" do
    store = Coverband.configuration.store
    assert store, "Store should be configured"

    # In this demo, we use either RedisStore or HashRedisStore
    store_class_name = store.class.name
    assert_includes(
      ["Coverband::Adapters::RedisStore", "Coverband::Adapters::HashRedisStore"],
      store_class_name,
      "Should be using a Redis-based store"
    )
  end

  # Test: View tracking configuration
  # Shows how view tracking can be enabled/disabled
  test "view tracking configuration is accessible" do
    # The configuration should respond to track_views
    assert Coverband.configuration.respond_to?(:track_views),
           "Configuration should support view tracking"

    # Current setting is determined by environment variable
    expected_value = ENV.fetch("COVERBAND_TRACK_VIEWS", "true") == "true"
    assert_equal expected_value, Coverband.configuration.track_views,
                 "View tracking should match environment configuration"
  end

  # Test: Translation tracking configuration
  # Demonstrates I18n key tracking setup
  test "translation tracking configuration is accessible" do
    assert Coverband.configuration.respond_to?(:track_translations),
           "Configuration should support translation tracking"

    expected_value = ENV.fetch("COVERBAND_TRACK_TRANSLATIONS", "true") == "true"
    assert_equal expected_value, Coverband.configuration.track_translations,
                 "Translation tracking should match environment configuration"
  end

  # Test: Route tracking configuration
  # Shows how route tracking can be configured
  test "route tracking configuration is accessible" do
    assert Coverband.configuration.respond_to?(:track_routes),
           "Configuration should support route tracking"

    expected_value = ENV.fetch("COVERBAND_TRACK_ROUTES", "true") == "true"
    assert_equal expected_value, Coverband.configuration.track_routes,
                 "Route tracking should match environment configuration"
  end

  # Test: Verbose mode configuration
  # Demonstrates how to enable verbose logging for debugging
  test "verbose mode can be configured" do
    assert Coverband.configuration.respond_to?(:verbose),
           "Configuration should support verbose mode"

    expected_value = ENV.fetch("COVERBAND_VERBOSE", "false") == "true"
    assert_equal expected_value, Coverband.configuration.verbose,
                 "Verbose mode should match environment configuration"
  end

  # Test: Web interface clear button
  # Shows how to enable/disable the clear button in the web UI
  test "web clear button is configurable" do
    assert Coverband.configuration.respond_to?(:web_enable_clear),
           "Configuration should support web clear button"

    # In this demo, we enable it for easy testing
    assert Coverband.configuration.web_enable_clear,
           "Web clear button should be enabled in demo"
  end

  # Test: Background reporting interval
  # Demonstrates how to configure how often coverage is reported
  test "background reporting interval is configurable" do
    assert Coverband.configuration.respond_to?(:background_reporting_sleep_seconds),
           "Configuration should support background reporting interval"

    # In development, we use a short interval for quick feedback
    assert_equal 10, Coverband.configuration.background_reporting_sleep_seconds,
                 "Background reporting should run every 10 seconds in development"
  end

  # Test: Reporting wiggle (randomization)
  # Shows how to add randomization to avoid thundering herd
  test "reporting wiggle is configurable" do
    assert Coverband.configuration.respond_to?(:reporting_wiggle),
           "Configuration should support reporting wiggle"

    assert_equal 2, Coverband.configuration.reporting_wiggle,
                 "Reporting wiggle should be configured"
  end

  # Test: Logger configuration
  # Demonstrates that Coverband uses the Rails logger
  test "should use rails logger" do
    assert_equal Rails.logger, Coverband.configuration.logger,
                 "Coverband should use Rails logger"
  end

  # Test: Store has required methods
  # Verifies that the storage adapter implements required interface
  test "store should implement required methods" do
    store = Coverband.configuration.store

    # All stores should implement these methods
    assert store.respond_to?(:clear!), "Store should support clearing data"
    assert store.respond_to?(:coverage), "Store should provide coverage data"
  end
end
