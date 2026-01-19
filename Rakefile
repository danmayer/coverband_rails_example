# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

###
# This can be used to verify and check various performance improvements.
# * run with COVERBAND_DISABLE_AUTO_START=true to avoid coverage collection polluting the results
#
# Example usage (against files in the demo app):
# COVERBAND_DISABLE_AUTO_START=true bundle exec rake coverband_benchmark
# 0.011663   0.000529   0.012192 (  0.013486)
#
# Example after adding 1000 files to the app/models directory:
#
# 0.184597   0.010427   0.195024 (  0.215962)
# You can run against the hash store to compare:
# COVERBAND_DISABLE_AUTO_START=true COVERBAND_HASH_STORE=true bundle exec rake coverband_benchmark
# sudo systemctl start toxiproxy
###
desc "Benchmark the performance of the Coverband coverage page"
task coverband_benchmark: :environment do
  Coverband.configure
  # add 50ms of latency to the redis connection
  Toxiproxy[/redis/].downstream(:latency, latency: 50).apply do
    data = Benchmark.measure do
      if ENV["COVERBAND_PAGER"]
        Coverband::Reporters::WebPager.new.tap do |cov|
          cov.instance_variable_set(:@request, Rack::Request.new(Rack::MockRequest.env_for("/?page=2")))
        end.index
      else
        Coverband::Reporters::Web.new.tap do |cov|
          cov.instance_variable_set(:@request, Rack::Request.new(Rack::MockRequest.env_for("/")))
        end.index
      end
    end
    puts data
  end
end

desc "Benchmark the performance of the Coverband coverage page"
task coverband_benchmark_single_file: :environment do
  Coverband.configure
  # add 25ms of latency to the redis connection
  Toxiproxy[/redis/].downstream(:latency, latency: 25).apply do
    file_url = "/coverage/load_file_details?filename="
    file_url += "/home/danmayer/projects/coverband_rails_example/lib/tasks/docker.rake"
    data = Benchmark.measure do
      if ENV["COVERBAND_PAGER"]
        Coverband::Reporters::WebPager.new.tap do |cov|
          cov.instance_variable_set(:@request,
                                    Rack::Request.new(Rack::MockRequest.env_for(file_url)))
        end.load_file_details
      else
        Coverband::Reporters::Web.new.tap do |cov|
          cov.instance_variable_set(:@request,
                                    Rack::Request.new(Rack::MockRequest.env_for(file_url)))
        end.load_file_details
      end
    end
    puts data
  end
end

###
# Test against:
# * gzip original set get.... msgpack original set get
# * look at a paging solution for the web interface
###
#
# Example usage:
# * COVERBAND_DISABLE_AUTO_START=true FILE_COUNT=4500 bundle exec rake generate_files
# * COVERBAND_REDIS_COMPRESSION=true FILE_COUNT=4500 bundle exec rake execute_files
# * COVERBAND_REDIS_COMPRESSION=true COVERBAND_DISABLE_AUTO_START=true
#   BENCHMARK_COVERBAND=true bundle exec rake coverband_benchmark
desc "generate a bunch of files to show impact of various project file counts"
task generate_files: :environment do
  (ENV["FILE_COUNT"] || 1000).to_i.times do |i|
    file_content = <<~TEXT
      class Generated#{i} < ApplicationRecord
          def self.bark
              "woof"
          end

          def never_called
              "meow"
          end
      end
    TEXT

    File.write("app/models/generated_#{i}.rb", file_content)
  end
end

desc "ensure all the generated files are loaded and executed creating coverage data"
task execute_files: :environment do
  (ENV["FILE_COUNT"] || 1000).to_i.times do |i|
    # rubocop:disable Security/Eval, Style/DocumentDynamicEvalDefinition, Style/EvalWithLocation
    eval "Generated#{i}.bark"
    # rubocop:enable Security/Eval, Style/DocumentDynamicEvalDefinition, Style/EvalWithLocation
  end
  nil
end

###
# Memory profiling tasks
###

desc "Profile memory usage with Coverband enabled"
task memory_profile: :environment do
  require "objspace"

  puts "=== Memory Profile (Coverband Enabled) ==="
  puts "Ruby Version: #{RUBY_VERSION}"
  puts "Rails Version: #{Rails.version}"
  puts ""

  # Force GC to get clean baseline
  GC.start

  # Object counts
  objects = ObjectSpace.count_objects
  puts "Total Objects: #{objects[:TOTAL].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  puts "Free Objects:  #{objects[:FREE].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  puts "Strings:       #{objects[:T_STRING].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  puts "Arrays:        #{objects[:T_ARRAY].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  puts "Hashes:        #{objects[:T_HASH].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  puts ""

  # Process memory (Linux only)
  if File.exist?("/proc/#{Process.pid}/status")
    status = File.read("/proc/#{Process.pid}/status")
    vm_size = status[/VmSize:\s+(\d+)/, 1]
    vm_rss = status[/VmRSS:\s+(\d+)/, 1]
    puts "VM Size (Virtual Memory): #{(vm_size.to_i / 1024.0).round(1)} MB"
    puts "RSS (Resident Set Size):  #{(vm_rss.to_i / 1024.0).round(1)} MB"
  else
    puts "Process memory stats not available (not on Linux)"
  end
  puts ""

  # Coverband-specific stats
  if defined?(Coverband)
    puts "=== Coverband Configuration ==="
    puts "Track Views:        #{Coverband.configuration.track_views}"
    puts "Track Translations: #{Coverband.configuration.track_translations}"
    puts "Track Routes:       #{Coverband.configuration.track_routes}"
    puts "Store Type:         #{Coverband.configuration.store.class.name}"

    if Coverband.configuration.store.respond_to?(:coverage)
      tracked_files = begin
        Coverband.configuration.store.coverage.keys.length
      rescue StandardError
        0
      end
      puts "Tracked Files:      #{tracked_files}"
    end
  end
end

desc "Compare memory usage with and without Coverband"
task memory_compare: :environment do
  puts "=== Memory Comparison ==="
  puts "This task shows current memory with Coverband enabled."
  puts "To compare, restart with COVERBAND_DISABLE_AUTO_START=true and run again."
  puts ""

  Rake::Task["memory_profile"].invoke

  puts ""
  puts "To see memory without Coverband:"
  puts "  COVERBAND_DISABLE_AUTO_START=true bundle exec rake memory_profile"
end

desc "Profile memory usage during a simulated request"
task memory_request_profile: :environment do
  require "objspace"

  puts "=== Memory Profile During Request Simulation ==="

  GC.start
  before_objects = ObjectSpace.count_objects[:TOTAL]
  before_rss = if File.exist?("/proc/#{Process.pid}/status")
                 status = File.read("/proc/#{Process.pid}/status")
                 status[/VmRSS:\s+(\d+)/, 1].to_i
               else
                 0
               end

  puts "Before: #{before_objects.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} objects"
  puts "Before RSS: #{(before_rss / 1024.0).round(1)} MB" if before_rss.positive?
  puts ""

  # Simulate some work
  puts "Simulating application work..."
  100.times do
    Post.all.to_a
    Book.all.to_a
  end

  GC.start
  after_objects = ObjectSpace.count_objects[:TOTAL]
  after_rss = if File.exist?("/proc/#{Process.pid}/status")
                status = File.read("/proc/#{Process.pid}/status")
                status[/VmRSS:\s+(\d+)/, 1].to_i
              else
                0
              end

  puts ""
  puts "After:  #{after_objects.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} objects"
  puts "After RSS: #{(after_rss / 1024.0).round(1)} MB" if after_rss.positive?
  puts ""
  puts "Difference: #{(after_objects - before_objects).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} objects"
  puts "RSS Difference: #{((after_rss - before_rss) / 1024.0).round(1)} MB" if after_rss.positive?
end

desc "Check Redis memory usage by Coverband"
task redis_memory_usage: :environment do
  puts "=== Coverband Redis Memory Usage ==="

  begin
    redis = Coverband.configuration.store.instance_variable_get(:@redis)

    # Get all Coverband keys
    keys = redis.keys("coverband*")
    puts "Total Coverband keys: #{keys.length}"
    puts ""

    # Sample some keys to estimate size
    sample_size = [keys.length, 10].min
    if sample_size.positive?
      puts "Sampling #{sample_size} keys:"
      total_sampled_size = 0

      keys.sample(sample_size).each do |key|
        size = redis.memory("USAGE", key)
        total_sampled_size += size
        puts "  #{key}: #{(size / 1024.0).round(2)} KB"
      rescue Redis::CommandError
        puts "  #{key}: [memory command not available]"
      end

      if total_sampled_size.positive?
        avg_key_size = total_sampled_size / sample_size
        estimated_total = (avg_key_size * keys.length) / 1024.0 / 1024.0
        puts ""
        puts "Estimated total Redis usage: #{estimated_total.round(2)} MB"
      end
    end

    # Redis info
    puts ""
    puts "Redis INFO:"
    info = redis.info("memory")
    puts "  Used Memory: #{(info["used_memory"].to_i / 1024.0 / 1024.0).round(2)} MB"
    puts "  Peak Memory: #{(info["used_memory_peak"].to_i / 1024.0 / 1024.0).round(2)} MB"
  rescue StandardError => e
    puts "Error accessing Redis: #{e.message}"
    puts "Make sure Redis is running and Coverband is configured."
  end
end

desc "Benchmark runtime overhead of code execution"
task runtime_overhead: :environment do
  puts "=== Runtime Overhead Benchmark ==="
  puts "Measures the overhead of executing code with Coverband coverage"
  puts ""

  iterations = (ENV["ITERATIONS"] || 1000).to_i
  puts "Running #{iterations} iterations..."
  puts ""

  # Test simple method calls
  data = Benchmark.measure do
    iterations.times do
      Post.all.to_a
      Book.all.to_a
    end
  end

  puts "Simple queries (#{iterations} iterations):"
  puts data
  puts ""
  puts "Average per iteration: #{((data.total / iterations) * 1000).round(3)} ms"
  puts ""
  puts "To compare without Coverband:"
  puts "  COVERBAND_DISABLE_AUTO_START=true bundle exec rake runtime_overhead"
end
