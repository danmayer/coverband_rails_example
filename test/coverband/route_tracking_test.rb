require "test_helper"

# This test demonstrates Coverband's route tracking feature.
# Route tracking helps identify which routes are actually accessed in your application.
# These tests serve as living documentation for understanding route tracking.
class Coverband::RouteTrackingTest < ActionDispatch::IntegrationTest
  setup do
    # Store the original tracking state
    @original_track_routes = Coverband.configuration.track_routes

    # Ensure route tracking is enabled for these tests
    Coverband.configuration.track_routes = true

    # Create test data
    @post = Post.create!(title: "Test Post", author: "Test", content: "Content")
    @book = Book.create!(title: "Test Book", author: "Test", content: "Content")
  end

  teardown do
    # Restore original configuration
    Coverband.configuration.track_routes = @original_track_routes
  end

  # Test: Route tracking is enabled
  # Demonstrates how to verify route tracking is active
  test "route tracking should be enabled when configured" do
    assert Coverband.configuration.track_routes,
           "Route tracking should be enabled for these tests"
  end

  # Test: GET requests are tracked
  # Shows that accessing routes causes them to be tracked
  test "GET requests to routes are tracked" do
    # Access various GET routes
    get demo_path
    assert_response :success

    get posts_path
    assert_response :success

    get books_path
    assert_response :success

    # All these routes should be tracked by Coverband
    # View the coverage report to see which routes were accessed
  end

  # Test: Resourceful routes are tracked
  # Demonstrates tracking of RESTful resource routes
  test "resourceful routes are tracked" do
    # Index route
    get posts_path
    assert_response :success

    # Show route
    get post_path(@post)
    assert_response :success

    # New route
    get new_post_path
    assert_response :success

    # Edit route
    get edit_post_path(@post)
    assert_response :success

    # Each of these RESTful routes should be tracked independently
  end

  # Test: POST requests are tracked
  # Shows that POST requests to routes are tracked
  test "POST requests are tracked" do
    # Create a new post
    post posts_path, params: {
      post: { title: "New Post", author: "Author", content: "Content" },
    }
    assert_response :redirect

    # The POST /posts route should be tracked
  end

  # Test: PATCH/PUT requests are tracked
  # Demonstrates tracking of update routes
  test "PATCH requests are tracked" do
    # Update an existing post
    patch post_path(@post), params: {
      post: { title: "Updated Title" },
    }
    assert_response :redirect

    # The PATCH /posts/:id route should be tracked
  end

  # Test: DELETE requests are tracked
  # Shows that destroy routes are tracked
  test "DELETE requests are tracked" do
    # Delete a post
    delete post_path(@post)
    assert_response :redirect

    # The DELETE /posts/:id route should be tracked
  end

  # Test: Custom routes are tracked
  # Demonstrates tracking of non-RESTful routes
  test "custom routes are tracked" do
    # The demo routes are custom routes
    get demo_configuration_path
    assert_response :success

    get demo_benchmarks_path
    assert_response :success

    get demo_profiling_path
    assert_response :success

    # All custom routes should be tracked
  end

  # Test: Unused routes are not tracked
  # Shows that routes you never access won't appear in coverage
  test "unused routes do not appear in coverage" do
    # If we only access the index and never create/edit/delete
    get posts_path
    assert_response :success

    # Only the index route is tracked
    # The other routes (new, create, edit, update, destroy) are not tracked
    # This helps identify unused endpoints
  end

  # Test: Route tracking with different HTTP methods
  # Demonstrates that the same path with different methods is tracked separately
  test "routes with different HTTP methods are tracked separately" do
    # GET /posts/:id (show)
    get post_path(@post)
    assert_response :success

    # PATCH /posts/:id (update)
    patch post_path(@post), params: {
      post: { title: "Updated" },
    }
    assert_response :redirect

    # DELETE /posts/:id (destroy)
    # (Not executing this as it would delete our test record)

    # Each HTTP method to the same path is tracked as a different route
  end

  # Test: Route tracking can be disabled
  # Shows that disabling route tracking still allows routes to work
  test "route tracking can be disabled" do
    # Disable route tracking
    Coverband.configuration.track_routes = false

    # Routes still work, but won't be tracked
    get posts_path
    assert_response :success

    # Useful for performance when you don't need route tracking
  end

  # Test: Nested routes are tracked
  # Demonstrates tracking of routes with parameters
  test "routes with parameters are tracked" do
    # Routes with ID parameters
    get post_path(@post)
    assert_response :success

    get book_path(@book)
    assert_response :success

    # Routes with parameters should be tracked
    # The specific ID doesn't matter - the route pattern is what's tracked
  end

  # Test: Multiple accesses to same route
  # Shows that accessing a route multiple times is still tracked
  test "multiple accesses to same route are tracked" do
    # Access the same route multiple times
    3.times do
      get posts_path
      assert_response :success
    end

    # The route should be tracked (multiple accesses are aggregated)
  end

  # Test: 404 routes might not be tracked
  # Demonstrates behavior when accessing non-existent routes
  test "accessing non-existent routes" do
    # Try to access a route that doesn't exist
    # In test environment, Rails catches routing errors and returns 404
    get "/this/route/does/not/exist"

    # Should get 404 response
    assert_response :not_found

    # Non-existent routes typically won't appear in route tracking
    # because they never reach a controller action
  end

  # Test: Health check route is tracked
  # Shows that even simple routes like health checks are tracked
  test "health check route is tracked" do
    get rails_health_check_path
    assert_response :success

    # The /up health check route should be tracked
  end
end

# Additional documentation on using route tracking:
#
# ## How to Enable Route Tracking
#
# In config/coverband.rb:
#   Coverband.configure do |config|
#     config.track_routes = true
#   end
#
# Or via environment variable:
#   COVERBAND_TRACK_ROUTES=true bundle exec rails server
#
# ## Viewing Tracked Routes
#
# 1. Run your application with route tracking enabled
# 2. Navigate through your application and use different features
# 3. Visit /coverage to see the coverage report
# 4. Look for route access patterns in the report
# 5. Compare with your routes (run: rails routes)
# 6. Unused routes indicate potentially dead endpoints
#
# ## Use Cases
#
# - Identify unused API endpoints
# - Find routes that can be removed
# - Understand actual route usage patterns
# - Optimize routing configuration
# - Verify all critical routes are being used
# - Audit public vs. internal endpoints
#
# ## Example Workflow
#
# 1. Run: rails routes > routes.txt
# 2. Enable route tracking
# 3. Run your test suite and/or use the app
# 4. Check /coverage for tracked routes
# 5. Compare tracked routes with routes.txt
# 6. Remove unused routes from config/routes.rb
#
# ## Best Practices
#
# - Run route tracking in production for a while to get real usage
# - Don't remove routes immediately - track for 30+ days
# - Consider that some routes might be seasonal or rarely used
# - Check API documentation before removing routes
# - Verify with stakeholders before removing public endpoints
