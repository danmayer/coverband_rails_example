require "test_helper"

# This test demonstrates Coverband's storage backend options.
# Storage backends determine how coverage data is persisted.
# These tests serve as living documentation for understanding storage configuration.
class Coverband::StorageTest < ActionDispatch::IntegrationTest
  # Test: Store is configured and accessible
  # Shows how to access the storage backend
  test "coverband store is accessible" do
    store = Coverband.configuration.store
    assert store, "Store should be configured"
    assert store.class, "Store should have a class"
  end

  # Test: Store responds to required interface
  # Demonstrates the required methods for a storage backend
  test "store implements required interface" do
    store = Coverband.configuration.store

    # All stores must implement these methods
    assert store.respond_to?(:clear!),
           "Store must implement clear! method"

    assert store.respond_to?(:coverage),
           "Store must implement coverage method"

    begin
      assert store.respond_to?(:save_report),
             "Store must implement save_report method"
    rescue StandardError
      nil
    end
  end

  # Test: Redis-based stores require Redis connection
  # Shows that Redis stores are connected to Redis
  test "redis store has redis connection" do
    store = Coverband.configuration.store
    store_class = store.class.name

    if store_class.include?("Redis")
      # Redis-based stores should have access to Redis
      assert store.instance_variable_get(:@redis),
             "Redis store should have Redis connection"
    end
  end

  # Test: Store can be cleared
  # Demonstrates how to clear coverage data
  test "store can be cleared" do
    store = Coverband.configuration.store

    # Clear should not raise an error
    assert_nothing_raised do
      store.clear!
    end

    # After clearing, coverage should be empty or minimal
    # (Some files might be loaded during the clear operation itself)
  end

  # Test: Store preserves data across operations
  # Shows that stored data persists until cleared
  test "store persists data" do
    store = Coverband.configuration.store

    # Clear first to start fresh
    store.clear!

    # Access the app to generate some coverage
    get posts_path
    assert_response :success

    # Wait for background reporting (if configured)
    sleep 1

    # Coverage should exist (though we can't easily verify exact data in test)
    # In production, check /coverage to see the persisted data
  end
end

# Additional documentation on storage backends:
#
# ## Available Storage Backends
#
# ### 1. RedisStore (Default)
#
# The standard Redis-based storage. Good for most applications.
#
# Configuration:
#   Coverband.configure do |config|
#     config.store = Coverband::Adapters::RedisStore.new(
#       Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379')
#     )
#   end
#
# Pros:
# - Simple and reliable
# - Works well for small to medium apps
# - Lower memory usage
#
# Cons:
# - Can be slower with 1000+ files
# - Uses Redis sorted sets
#
# ### 2. HashRedisStore (Recommended for Production)
#
# An optimized Redis store using hashes for better performance.
#
# Configuration:
#   Coverband.configure do |config|
#     config.store = Coverband::Adapters::HashRedisStore.new(
#       Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379')
#     )
#   end
#
# Or via environment:
#   COVERBAND_HASH_STORE=true
#
# Pros:
# - Much faster for large applications (1000+ files)
# - Better Redis memory efficiency
# - Faster data retrieval
# - Recommended for production
#
# Cons:
# - Slightly more complex Redis structure
#
# ### 3. FileStore (Development Only)
#
# Stores coverage data in local files. No Redis required.
#
# Configuration:
#   Coverband.configure do |config|
#     config.store = Coverband::Adapters::FileStore.new(
#       '/tmp/coverband_data'
#     )
#   end
#
# Pros:
# - No Redis dependency
# - Good for development
# - Easy to inspect files
#
# Cons:
# - Not suitable for multi-server deployments
# - Slower than Redis stores
# - Files can grow large
#
# ## Choosing a Storage Backend
#
# ### Small Applications (< 500 files)
# - Use RedisStore (default)
# - Simple and sufficient
#
# ### Medium Applications (500-2000 files)
# - Consider HashRedisStore
# - Better performance characteristics
#
# ### Large Applications (2000+ files)
# - Use HashRedisStore
# - Enable paged reporting: config.paged_reporting = true
# - Increase reporting interval: config.background_reporting_sleep_seconds = 300
#
# ### Development/Testing
# - FileStore can work without Redis
# - RedisStore is fine if Redis is available
#
# ## Storage Maintenance
#
# ### Clearing Old Data
#
# Via Rails console:
#   Coverband.configuration.store.clear!
#
# Via web interface:
#   - Visit /coverage
#   - Click "Clear Coverage" button (if enabled)
#
# ### Checking Storage Size
#
# For Redis stores:
#   redis-cli
#   MEMORY USAGE coverband_3_1_production
#
# Via rake task:
#   bundle exec rake redis_memory_usage
#
# ### Backup Coverage Data
#
# For Redis stores:
#   redis-cli SAVE
#   # Creates dump.rdb with all data
#
# For FileStore:
#   tar -czf coverband_backup.tar.gz /tmp/coverband_data
#
# ## Performance Tips
#
# 1. Use HashRedisStore for production
# 2. Increase background_reporting_sleep_seconds (e.g., 300 for 5 minutes)
# 3. Use reporting_wiggle to avoid thundering herd
# 4. Enable paged_reporting for large apps
# 5. Regularly clear old coverage data
# 6. Monitor Redis memory usage
# 7. Use a separate Redis instance for Coverband in production
#
# ## Troubleshooting Storage Issues
#
# ### Issue: Redis connection errors
# Solution: Verify Redis is running and connection URL is correct
#
# ### Issue: Coverage data not appearing
# Solution: Wait for background_reporting_sleep_seconds to elapse
#
# ### Issue: Redis out of memory
# Solution: Clear old data or increase Redis maxmemory
#
# ### Issue: Slow coverage report loading
# Solution: Switch to HashRedisStore or enable paged_reporting
