Coverband.configure do |config|
  config.logger = defined?(Rails) ? Rails.logger : Logger.new($stdout)

  # ActiveSupport::Cache adapter (Coverband 7.0+)
  # COVERBAND_CACHE_STORE=redis|memcached|solid_cache|rails_cache
  # The cache itself is built in config/environments/development.rb so this uses
  # the documented lazy block form: Rails.cache does not exist yet at this point.
  if (coverband_cache_store = ENV.fetch("COVERBAND_CACHE_STORE", nil))
    config.store =
      if ENV["COVERBAND_CACHE_EAGER"]
        # eager form: hand the adapter a store built right here
        cache =
          case coverband_cache_store
          when "redis"
            ActiveSupport::Cache::RedisCacheStore.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"))
          when "memcached"
            ActiveSupport::Cache::MemCacheStore.new(ENV.fetch("MEMCACHED_URL", "localhost:11211"))
          when "solid_cache"
            SolidCache::Store.new(max_age: nil, max_entries: 100_000)
          end
        Coverband::Adapters::ActiveSupportCacheStore.new(cache)
      else
        Coverband::Adapters::ActiveSupportCacheStore.new { Rails.cache }
      end
  end

  if ENV["COVERBAND_HASH_STORE"] || ENV["COVERBAND_PAGER"]
    Rails.logger.debug "using hash store"
    redis_url = ENV["REDIS_URL"] || "redis://localhost:6379/0"
    config.store = Coverband::Adapters::HashRedisStore.new(Redis.new(url: redis_url))
  end

  if ENV["COVERBAND_PAGER"]
    Rails.logger.debug "setting paged reporting"
    config.paged_reporting = true
  end

  # config options false, true. (defaults to false)
  # true and debug can give helpful and interesting code usage information
  # and is safe to use if one is investigating issues in production, but it will slightly
  # hit perf.
  config.verbose = ENV.fetch("COVERBAND_VERBOSE", "false") == "true"

  # Keep the public report read-only in production. Enable this deliberately
  # when demonstrating destructive clear operations.
  config.web_enable_clear = ENV.fetch("COVERBAND_WEB_ENABLE_CLEAR", Rails.env.development?.to_s) == "true"

  # avoid all your servers reporting at once... In production I recommend 30
  config.reporting_wiggle = 2

  # In development we report more often than production.
  # In production I recommend every 5 minutes (300 seconds)
  # config.background_reporting_sleep_seconds = 300
  config.background_reporting_sleep_seconds = 10

  # View Tracker Configuration
  # Tracks which views are rendered in your application
  config.track_views = ENV.fetch("COVERBAND_TRACK_VIEWS", "true") == "true"

  # Translation Tracker Configuration
  # Tracks which I18n translation keys are used
  config.track_translations = ENV.fetch("COVERBAND_TRACK_TRANSLATIONS", "true") == "true"

  # Router Tracker Configuration
  # Tracks which routes are accessed in your application
  config.track_routes = ENV.fetch("COVERBAND_TRACK_ROUTES", "true") == "true"

  # Query Burst Tracker Configuration
  config.track_query_bursts = ENV.fetch("COVERBAND_TRACK_QUERY_BURSTS", "true") == "true"

  # MCP is opt-in and cannot be exposed without a secret. Production must also
  # be explicitly included because Coverband defaults MCP to development/test.
  if ENV.fetch("COVERBAND_MCP_ENABLED", "false") == "true"
    config.mcp_enabled = true
    config.mcp_allowed_environments = %w[development test production]
    config.mcp_password = ENV.fetch("COVERBAND_MCP_PASSWORD")
  end
end
