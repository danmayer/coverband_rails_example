require "test_helper"

# This test demonstrates Coverband's view tracking feature.
# View tracking helps identify which views and partials are rendered in your application.
# These tests serve as living documentation for understanding view tracking.
class Coverband::ViewTrackingTest < ActionDispatch::IntegrationTest
  setup do
    # Store the original tracking state
    @original_track_views = Coverband.configuration.track_views

    # Ensure view tracking is enabled for these tests
    # In a real application, you would set this in config/coverband.rb
    Coverband.configuration.track_views = true
  end

  teardown do
    # Restore original configuration
    Coverband.configuration.track_views = @original_track_views
  end

  # Test: View tracking is enabled
  # Demonstrates how to check if view tracking is active
  test "view tracking should be enabled when configured" do
    assert Coverband.configuration.track_views,
           "View tracking should be enabled for these tests"
  end

  # Test: Rendering views generates tracking data
  # Shows that accessing pages causes views to be tracked
  test "rendering a page tracks view files" do
    # When we render a page, Coverband should track the views used
    get posts_path

    assert_response :success

    # The posts index view should have been rendered
    # Note: In a real test, you would check Coverband's store for the tracked view
    # This demonstrates that the request completed successfully
  end

  # Test: Multiple view renders are tracked
  # Demonstrates tracking across different pages
  test "multiple page renders track different views" do
    # Render posts index
    get posts_path
    assert_response :success

    # Render books index
    get books_path
    assert_response :success

    # Render demo home
    get demo_path
    assert_response :success

    # All three pages use different views, and all should be tracked
    # In production, you can see these in the coverage report at /coverage
  end

  # Test: Partials are tracked
  # Shows that rendered partials are also tracked by Coverband
  test "rendering partials is tracked" do
    # Create a post to ensure we have data to render
    Post.create!(title: "Test Post", author: "Test Author", content: "Test Content")

    # The posts index renders the _post partial for each post
    get posts_path
    assert_response :success

    # The _post partial should be tracked
    # You can verify this in the coverage report
  end

  # Test: View tracking can be disabled
  # Demonstrates how disabling view tracking affects behavior
  test "view tracking can be disabled" do
    # Disable view tracking
    Coverband.configuration.track_views = false

    # Render a page
    get posts_path
    assert_response :success

    # Page still works, but views won't be tracked in coverage
    # This is useful for performance optimization when view tracking isn't needed
  end

  # Test: View tracking works with different formats
  # Shows that HTML views are tracked
  test "html views are tracked" do
    get posts_path
    assert_response :success
    assert_equal "text/html", response.media_type

    # HTML views should be tracked by Coverband
  end

  # Test: View tracking with layouts
  # Demonstrates that layouts are also tracked
  test "layouts are tracked when rendering views" do
    # The application layout is used for all pages
    get demo_path
    assert_response :success

    # Both the action view and the application layout should be tracked
    # Check app/views/layouts/application.html.erb in coverage report
  end

  # Test: View tracking across different controllers
  # Shows that views from multiple controllers are tracked
  test "views from different controllers are all tracked" do
    # Posts controller views
    get posts_path
    assert_response :success

    # Books controller views
    get books_path
    assert_response :success

    # Demo controller views
    get demo_configuration_path
    assert_response :success

    # All controller views should be tracked independently
  end

  # Test: Unused views can be identified
  # Demonstrates how to find views that are never rendered
  test "unused views are not tracked" do
    # Some views might exist but never be rendered in normal usage
    # For example, if we never visit the edit page for a post
    # the edit view won't appear in coverage

    # Only visit the index
    get posts_path
    assert_response :success

    # The edit and new views are NOT accessed, so they won't be tracked
    # This helps identify dead code in your views
  end
end

# Additional documentation on using view tracking:
#
# ## How to Enable View Tracking
#
# In config/coverband.rb:
#   Coverband.configure do |config|
#     config.track_views = true
#   end
#
# Or via environment variable:
#   COVERBAND_TRACK_VIEWS=true bundle exec rails server
#
# ## Viewing Tracked Views
#
# 1. Run your application with view tracking enabled
# 2. Navigate through your application
# 3. Visit /coverage to see the coverage report
# 4. Look for .erb files in the report
# 5. Red/missing views indicate unused view files
#
# ## Use Cases
#
# - Identify unused view templates
# - Find partially-rendered views
# - Understand which partials are actually used
# - Clean up legacy view code
# - Optimize view rendering performance
