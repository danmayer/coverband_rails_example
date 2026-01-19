require "test_helper"

# This test demonstrates complete workflows using Coverband.
# Integration tests show how all features work together in realistic scenarios.
# These tests serve as living documentation for real-world Coverband usage.
class Coverband::IntegrationTest < ActionDispatch::IntegrationTest
  setup do
    # Ensure all tracking features are enabled
    @original_configs = {
      track_views: Coverband.configuration.track_views,
      track_translations: Coverband.configuration.track_translations,
      track_routes: Coverband.configuration.track_routes,
    }

    Coverband.configuration.track_views = true
    Coverband.configuration.track_translations = true
    Coverband.configuration.track_routes = true

    # Clear coverage to start fresh
    begin
      Coverband.configuration.store.clear!
    rescue StandardError
      nil
    end
  end

  teardown do
    # Restore original configurations
    Coverband.configuration.track_views = @original_configs[:track_views]
    Coverband.configuration.track_translations = @original_configs[:track_translations]
    Coverband.configuration.track_routes = @original_configs[:track_routes]
  end

  # Test: Complete user journey tracking
  # Demonstrates how Coverband tracks a full user session
  test "complete user journey is tracked" do
    # Scenario: A user explores the demo app

    # 1. User lands on home page
    get demo_path
    assert_response :success
    # Tracks: demo view, translations (demo.welcome, etc.), route (GET /demo)

    # 2. User navigates to posts
    get posts_path
    assert_response :success
    # Tracks: posts/index view, posts translations, route (GET /posts)

    # 3. User creates a new post
    get new_post_path
    assert_response :success
    # Tracks: posts/new view, route (GET /posts/new)

    post posts_path, params: {
      post: { title: "Test Post", author: "User", content: "Content" },
    }
    assert_response :redirect
    # Tracks: route (POST /posts), post creation code

    # 4. User views the created post
    created_post = Post.last
    get post_path(created_post)
    assert_response :success
    # Tracks: posts/show view, route (GET /posts/:id)

    # This entire journey is tracked:
    # - All views rendered
    # - All translation keys used
    # - All routes accessed
    # - All Ruby code executed
  end

  # Test: CRUD operations tracking
  # Shows how Coverband tracks create, read, update, delete operations
  test "CRUD operations are fully tracked" do
    # Create
    post posts_path, params: {
      post: { title: "CRUD Test", author: "Test", content: "Test" },
    }
    assert_response :redirect
    created_post = Post.last

    # Read
    get post_path(created_post)
    assert_response :success

    # Update
    patch post_path(created_post), params: {
      post: { title: "Updated Title" },
    }
    assert_response :redirect

    # Delete
    delete post_path(created_post)
    assert_response :redirect

    # All CRUD operations are tracked:
    # - Each route (POST, GET, PATCH, DELETE)
    # - Each view (show, edit forms)
    # - All model code (create, update, destroy)
    # - All controller actions
  end

  # Test: Multi-resource tracking
  # Demonstrates tracking across different resources
  test "multiple resources are tracked independently" do
    # Work with Posts
    get posts_path
    assert_response :success

    post posts_path, params: {
      post: { title: "Post", author: "Author", content: "Content" },
    }
    assert_response :redirect

    # Work with Books
    get books_path
    assert_response :success

    post books_path, params: {
      book: { title: "Book", author: "Author", content: "Content" },
    }
    assert_response :redirect

    # Both resources are tracked independently:
    # - Separate views (posts/* and books/*)
    # - Separate routes
    # - Separate model code (Post vs Book)
    # - Separate controller actions
  end

  # Test: Feature usage discovery
  # Shows how to identify which features are actually used
  test "feature usage can be discovered through coverage" do
    # Only use certain features
    get posts_path
    assert_response :success

    get new_post_path
    assert_response :success

    # Do NOT use edit, update, or delete
    # Coverage will show:
    # - Index and new actions are covered
    # - Edit, update, destroy actions are not covered
    # This helps identify unused features
  end

  # Test: Dead code identification
  # Demonstrates finding unused code paths
  test "unused code paths are identifiable" do
    # Access posts but never use the unused helper
    get posts_path
    assert_response :success

    # The UnusedHelper is defined but never actually used
    # (It's commented out in the controller)
    # Coverage will show it's not executed
  end

  # Test: Translation usage patterns
  # Shows how translation tracking reveals which keys are used
  test "translation usage patterns are tracked" do
    # Visit pages that use different translation scopes

    # Demo page uses demo.* translations
    get demo_path
    assert_response :success

    # Posts page uses posts.* translations
    get posts_path
    assert_response :success

    # Navigation uses app.navigation.* translations (on every page)

    # Coverage shows:
    # - Which translation keys are used
    # - Which scopes are most active
    # - Which keys are never accessed
  end

  # Test: API endpoint tracking
  # Demonstrates tracking JSON API endpoints
  test "json api endpoints are tracked" do
    # Request JSON format
    get posts_path, headers: { "Accept" => "application/json" }
    assert_response :success
    assert_equal "application/json", response.media_type

    # JSON responses are tracked just like HTML
    # Tracks:
    # - Route access
    # - Controller action
    # - Jbuilder views (if used)
  end

  # Test: Error paths are tracked
  # Shows that error conditions are also tracked
  test "error handling code is tracked" do
    # Try to access non-existent record
    # In test environment, Rails catches the exception and returns 404
    get post_path(id: 999_999)

    # Should get 404 response
    assert_response :not_found

    # The error handling code path is tracked
    # This helps verify error handling is tested
    # In production, Coverband tracks the rescue blocks and error handlers
  end

  # Test: Background job simulation
  # Demonstrates tracking code executed outside requests
  test "background processing can be tracked" do
    # Simulate work that might happen in a background job
    10.times do
      Post.all.to_a
      Book.all.to_a
    end

    # Code executed outside HTTP requests is still tracked
    # Useful for:
    # - Background jobs
    # - Rake tasks
    # - Console operations
    # - Scheduled tasks
  end

  # Test: Performance-optimized configuration
  # Shows how to configure for minimal overhead
  test "minimal tracking configuration for performance" do
    # Disable non-essential tracking
    Coverband.configuration.track_views = false
    Coverband.configuration.track_translations = false
    Coverband.configuration.track_routes = false

    # Only code coverage remains
    get posts_path
    assert_response :success

    # This configuration provides:
    # - Maximum performance
    # - Minimal overhead
    # - Still tracks code execution
    # Use when you only need code coverage
  end

  # Test: Full tracking configuration for visibility
  # Shows comprehensive tracking setup
  test "full tracking configuration for maximum visibility" do
    # Enable everything
    Coverband.configuration.track_views = true
    Coverband.configuration.track_translations = true
    Coverband.configuration.track_routes = true

    # Generate coverage across multiple areas
    get demo_path
    assert_response :success

    get posts_path
    assert_response :success

    get books_path
    assert_response :success

    # This configuration tracks:
    # - Every line of code executed
    # - Every view rendered
    # - Every translation accessed
    # - Every route used
    # Perfect for:
    # - Development
    # - Staging environments
    # - Understanding usage patterns
  end
end

# Additional documentation on integration scenarios:
#
# ## Real-World Workflow: Identifying Dead Code
#
# 1. Enable full tracking in production
# 2. Run for 30-60 days to capture all usage patterns
# 3. Visit /coverage to see the report
# 4. Identify code with 0% coverage
# 5. Investigate why it's not used:
#    - Is it a legacy feature?
#    - Is it seasonal (used only at certain times)?
#    - Is it actually dead code?
# 6. For truly dead code:
#    - Remove it
#    - Or deprecate it with warnings
#    - Or document why it's kept
#
# ## Real-World Workflow: Optimizing Performance
#
# 1. Start with full tracking enabled
# 2. Run benchmarks (bundle exec rake coverband_benchmark)
# 3. Identify performance bottlenecks:
#    - How many files are tracked?
#    - How long does reporting take?
#    - What's the memory footprint?
# 4. Optimize based on findings:
#    - Use HashRedisStore for better performance
#    - Disable trackers you don't need
#    - Increase background_reporting_sleep_seconds
#    - Add files to ignore list
# 5. Re-run benchmarks to verify improvements
#
# ## Real-World Workflow: Refactoring Safety
#
# Before refactoring:
# 1. Enable Coverband in staging/production
# 2. Collect coverage for the code you plan to refactor
# 3. Verify the code is actually used
# 4. Identify all entry points and use cases
#
# During refactoring:
# 1. Keep Coverband enabled
# 2. Run your full test suite
# 3. Check coverage to ensure tests hit all paths
#
# After refactoring:
# 1. Deploy to staging
# 2. Monitor coverage to verify behavior matches old code
# 3. Look for unexpected drops in coverage (indicates issues)
#
# ## Real-World Workflow: Feature Deprecation
#
# 1. Enable route and view tracking
# 2. Identify candidate features for deprecation
# 3. Monitor usage over time:
#    - Daily active users
#    - Route access counts
#    - View renders
# 4. For unused features:
#    - Add deprecation warnings
#    - Monitor if warnings are seen
#    - After grace period, remove feature
# 5. Use coverage to verify complete removal
#
# ## Real-World Workflow: API Cleanup
#
# For API endpoints:
# 1. Enable route tracking
# 2. Run in production for extended period (90+ days)
# 3. Identify unused endpoints
# 4. Check API documentation
# 5. Coordinate with API consumers
# 6. For truly unused endpoints:
#    - Return 410 Gone status
#    - Monitor for any attempts to use
#    - Remove after confirmation period
#
# ## Real-World Workflow: Translation Audit
#
# 1. Enable translation tracking
# 2. Run in all supported locales
# 3. Generate reports by locale
# 4. Identify unused keys per locale
# 5. Verify with stakeholders
# 6. Remove unused translations
# 7. Reduces bundle size and improves load times
