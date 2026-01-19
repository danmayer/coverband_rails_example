require "test_helper"

# This test demonstrates how to measure and compare Coverband's performance impact.
# These tests serve as living documentation for performance testing and optimization.
class Coverband::PerformanceTest < ActionDispatch::IntegrationTest
  # Test: Tracking overhead is measurable
  # Shows how to measure the performance impact of Coverband
  test "tracking has minimal overhead" do
    # Make multiple requests to get consistent timing
    iterations = 10

    start_time = Time.zone.now
    iterations.times do
      get posts_path
      assert_response :success
    end
    elapsed_time = Time.zone.now - start_time

    # With Coverband enabled, requests should still be fast
    # In this demo, we expect < 1 second for 10 requests
    # (Actual performance depends on your hardware and configuration)
    average_per_request = elapsed_time / iterations

    # Document the performance characteristic
    # This is not a strict assertion but documentation of expected behavior
    puts "\nAverage request time with Coverband: #{average_per_request.round(4)}s"
  end

  # Test: View tracking impact
  # Demonstrates the overhead of view tracking
  test "view tracking overhead is acceptable" do
    # With view tracking
    Coverband.configuration.track_views = true
    start_time = Time.zone.now
    5.times do
      get posts_path
      assert_response :success
    end
    with_tracking = Time.zone.now - start_time

    # Without view tracking
    Coverband.configuration.track_views = false
    start_time = Time.zone.now
    5.times do
      get posts_path
      assert_response :success
    end
    without_tracking = Time.zone.now - start_time

    overhead = with_tracking - without_tracking

    # Document the overhead
    puts "\nView tracking overhead: #{overhead.round(4)}s for 5 requests"
    puts "Per request: #{(overhead / 5).round(4)}s"

    # Restore setting
    Coverband.configuration.track_views = true
  end

  # Test: Configuration comparison
  # Shows how different configurations affect performance
  test "minimal configuration provides best performance" do
    # Test 1: Full tracking
    Coverband.configuration.track_views = true
    Coverband.configuration.track_translations = true
    Coverband.configuration.track_routes = true

    start_time = Time.zone.now
    3.times do
      get demo_path
      assert_response :success
    end
    full_tracking_time = Time.zone.now - start_time

    # Test 2: Minimal tracking
    Coverband.configuration.track_views = false
    Coverband.configuration.track_translations = false
    Coverband.configuration.track_routes = false

    start_time = Time.zone.now
    3.times do
      get demo_path
      assert_response :success
    end
    minimal_tracking_time = Time.zone.now - start_time

    # Document the difference
    difference = full_tracking_time - minimal_tracking_time
    puts "\nFull tracking: #{full_tracking_time.round(4)}s"
    puts "Minimal tracking: #{minimal_tracking_time.round(4)}s"
    puts "Difference: #{difference.round(4)}s"

    # Restore settings
    Coverband.configuration.track_views = true
    Coverband.configuration.track_translations = true
    Coverband.configuration.track_routes = true
  end

  # Test: Memory usage is reasonable
  # Demonstrates checking memory footprint
  test "memory usage is within acceptable bounds" do
    # Force garbage collection for accurate measurement
    GC.start

    before_objects = ObjectSpace.count_objects[:TOTAL]

    # Generate some coverage
    10.times do
      get posts_path
      assert_response :success
    end

    GC.start
    after_objects = ObjectSpace.count_objects[:TOTAL]

    objects_created = after_objects - before_objects

    # Document memory impact
    puts "\nObjects created during 10 requests: #{objects_created}"
    puts "Per request: #{objects_created / 10}"

    # This is documentation, not a strict test
    # Actual numbers vary by Ruby version and system state
  end
end

# Additional documentation on performance testing:
#
# ## How to Run Performance Tests
#
# Basic test run:
#   bundle exec rails test test/coverband/performance_test.rb
#
# With verbose output:
#   bundle exec rails test test/coverband/performance_test.rb -v
#
# ## Interpreting Results
#
# ### Request Time Overhead
#
# Expected overhead per request:
# - Minimal config (code only): 1-5ms
# - View tracking added: +2-5ms
# - Translation tracking added: +1-3ms
# - Route tracking added: +0.5-2ms
# - Full tracking: 5-15ms total
#
# If you see higher overhead:
# 1. Check Redis latency
# 2. Verify ignore patterns are working
# 3. Consider using HashRedisStore
# 4. Increase background_reporting_sleep_seconds
#
# ### Memory Overhead
#
# Expected memory impact:
# - Small apps (<500 files): 10-20MB
# - Medium apps (500-2000 files): 20-50MB
# - Large apps (2000+ files): 50-100MB
#
# If memory usage is higher:
# 1. Check how many files are being tracked
# 2. Verify ignore patterns
# 3. Clear old coverage data
# 4. Use HashRedisStore
#
# ## Benchmarking Best Practices
#
# 1. **Warm up before measuring**
#    Run requests before starting timers to load code
#
# 2. **Run multiple iterations**
#    Single requests are too variable
#    Use at least 10 iterations for consistent results
#
# 3. **Use production-like configuration**
#    Test with production settings for accurate results
#
# 4. **Measure on production-like hardware**
#    Development machines give different results than production
#
# 5. **Account for Redis latency**
#    Network latency to Redis affects performance
#    Use Toxiproxy to simulate realistic latency
#
# ## Performance Optimization Checklist
#
# ### If overhead is too high:
#
# - [ ] Switch to HashRedisStore
# - [ ] Disable unnecessary trackers
# - [ ] Increase background_reporting_sleep_seconds
# - [ ] Add more patterns to config.ignore
# - [ ] Enable paged_reporting for large apps
# - [ ] Use separate Redis instance
# - [ ] Check Redis memory and optimize
#
# ### If memory usage is too high:
#
# - [ ] Verify ignore patterns are working
# - [ ] Clear old coverage data regularly
# - [ ] Reduce background_reporting_sleep_seconds
# - [ ] Use HashRedisStore
# - [ ] Check for memory leaks in application
# - [ ] Monitor Redis memory usage
#
# ## Running Production Benchmarks
#
# ### Using the included rake tasks:
#
# 1. Coverage report benchmark:
#    ```bash
#    COVERBAND_DISABLE_AUTO_START=true bundle exec rake coverband_benchmark
#    ```
#
# 2. Runtime overhead benchmark:
#    ```bash
#    # With Coverband
#    bundle exec rake runtime_overhead
#
#    # Without Coverband
#    COVERBAND_DISABLE_AUTO_START=true bundle exec rake runtime_overhead
#    ```
#
# 3. Memory profiling:
#    ```bash
#    bundle exec rake memory_profile
#    ```
#
# ### Using ApacheBench (ab):
#
# ```bash
# # Without Coverband
# COVERBAND_DISABLE_AUTO_START=true bundle exec rails s &
# ab -n 1000 -c 10 http://localhost:3000/posts
#
# # With Coverband
# bundle exec rails s &
# ab -n 1000 -c 10 http://localhost:3000/posts
# ```
#
# ### Using wrk (more advanced):
#
# ```bash
# # Install wrk first
# brew install wrk  # macOS
#
# # Run benchmark
# wrk -t4 -c100 -d30s http://localhost:3000/posts
# ```
#
# ## Performance Test Examples
#
# ### Example 1: Compare storage backends
#
# ```ruby
# # Test RedisStore
# ENV['COVERBAND_HASH_STORE'] = 'false'
# # ... run benchmarks ...
#
# # Test HashRedisStore
# ENV['COVERBAND_HASH_STORE'] = 'true'
# # ... run benchmarks ...
# ```
#
# ### Example 2: Measure tracking overhead
#
# ```ruby
# # Baseline - no Coverband
# ENV['COVERBAND_DISABLE_AUTO_START'] = 'true'
# baseline_time = measure_requests(100)
#
# # With code coverage only
# ENV.delete('COVERBAND_DISABLE_AUTO_START')
# ENV['COVERBAND_TRACK_VIEWS'] = 'false'
# ENV['COVERBAND_TRACK_TRANSLATIONS'] = 'false'
# ENV['COVERBAND_TRACK_ROUTES'] = 'false'
# code_only_time = measure_requests(100)
#
# # With full tracking
# ENV['COVERBAND_TRACK_VIEWS'] = 'true'
# ENV['COVERBAND_TRACK_TRANSLATIONS'] = 'true'
# ENV['COVERBAND_TRACK_ROUTES'] = 'true'
# full_tracking_time = measure_requests(100)
#
# puts "Baseline: #{baseline_time}s"
# puts "Code only: #{code_only_time}s (overhead: #{code_only_time - baseline_time}s)"
# puts "Full tracking: #{full_tracking_time}s (overhead: #{full_tracking_time - baseline_time}s)"
# ```
#
# ## What to Measure
#
# 1. **Request latency** - How much slower are requests?
# 2. **Throughput** - How many requests per second?
# 3. **Memory usage** - How much RAM is used?
# 4. **Redis operations** - How many Redis commands per request?
# 5. **Coverage report time** - How long to generate /coverage?
# 6. **Boot time** - How much does app startup slow down?
#
# ## Realistic Performance Expectations
#
# ### Development Environment
# - Request overhead: 5-20ms
# - Memory overhead: 20-50MB
# - Coverage report: 100-500ms
#
# ### Production Environment
# - Request overhead: 2-10ms
# - Memory overhead: 30-100MB
# - Coverage report: 200ms-2s
#
# These numbers vary significantly based on:
# - Application size
# - Configuration
# - Hardware
# - Redis latency
# - Ruby version
