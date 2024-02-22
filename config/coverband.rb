Coverband.configure do |config|
    config.logger = Rails.logger

    if ENV["COVERBAND_HASH_STORE"]
      puts "using hash store"
      config.store = Coverband::Adapters::HashRedisStore.new(Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0'))
    end

    # config options false, true. (defaults to false)
    # true and debug can give helpful and interesting code usage information
    # and is safe to use if one is investigating issues in production, but it will slightly
    # hit perf.
    config.verbose = false
  
    # default false. button at the top of the web interface which clears all data
    config.web_enable_clear = true

    # avoid all your servers reporting at once... In production I recommend 30
    config.reporting_wiggle = 2

    # in developer mode we want to report more often than in production, in production I often set this to every 5 minutes (300 seconds)
    config.background_reporting_sleep_seconds = 20000
    # config.background_reporting_sleep_seconds = 2
  end