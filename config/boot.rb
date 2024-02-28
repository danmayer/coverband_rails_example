ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

require 'toxiproxy'

if ENV["BENCHMARK_COVERBAND"]
    ENV['REDIS_URL'] = "redis://127.0.0.1:22222"

    # make sure toxiproxy is running
    # sudo service toxiproxy start

    Toxiproxy.populate([
    {
        name: "toxiproxy_test_redis",
        listen: "127.0.0.1:22222",
        upstream: "127.0.0.1:6379"
    }
    ])
end