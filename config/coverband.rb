Coverband.configure do |config|
  config.logger = defined?(Rails) ? Rails.logger : Logger.new($stdout)

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

  # default false. button at the top of the web interface which clears all data
  config.web_enable_clear = true

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

  # MCP Configuration
  config.mcp_enabled = true
  config.mcp_password = ENV["COVERBAND_MCP_PASSWORD"] || "dev-password-123"
end
