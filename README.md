# Coverband Rails Demo

A comprehensive demonstration application showcasing all of [Coverband's](https://github.com/danmayer/coverband) features, configuration options, and performance characteristics. This demo helps you understand how Coverband works and how to integrate it into your Rails applications.

## What is Coverband?

Coverband is a Ruby code coverage tool for production environments. Unlike traditional test coverage tools, Coverband tracks which code is actually executed in production, helping you:

- Identify dead code and unused features
- Track view, translation, and route usage
- Understand runtime code execution patterns
- Make informed decisions about refactoring and deprecation

## Features Demonstrated

This demo showcases all major Coverband features:

# Deploy to Render

This application is configured to be easily deployed on [Render.com](https://render.com).

1.  Fork this repository.
2.  Create a new Web Service on Render.
3.  Connect your GitHub account and select your forked repository.
4.  Render will automatically detect the `render.yaml` blueprint (or you can select "Docker" as the runtime).
5.  **Important:** Coverband requires Redis. Render does not offer a free Redis instance that persists.
    *   Sign up for a free Redis instance at [Upstash](https://upstash.com/) or [Redis Cloud](https://redis.com/try-free/).
    *   Get your Redis connection URL (e.g., `redis://default:password@fly-foo-bar.upstash.io:6379`).
    *   In the Render dashboard for your service, add an Environment Variable named `REDIS_URL` with your connection string.
✅ **Code Coverage Tracking** - Real-time line-by-line coverage analysis
✅ **View Tracking** - Monitor which views and partials are rendered
✅ **Translation Tracking** - Discover which I18n keys are used
✅ **Router Tracking** - Track which routes are accessed
✅ **Configuration Options** - Test different storage backends and settings
✅ **Performance Benchmarks** - Measure Coverband's impact
✅ **Memory Profiling** - Understand memory usage and overhead

## Quick Start

### Prerequisites

- Ruby 3.4.7 (or 3.2+)
- Rails 7.1+
- Redis (for coverage storage)

### Installation

```bash
git clone git@github.com:danmayer/coverband_rails_example.git
cd coverband_rails_example
bundle install
```

### Setup Database

```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed  # Optional: create sample data
```

### Start Redis

```bash
# macOS with Homebrew
brew services start redis

# Linux
sudo systemctl start redis

# Or run directly
redis-server
```

### Start the Application

```bash
bundle exec rails server
```

### Explore the Demo

Open your browser and visit:

- **Demo Home**: http://localhost:3000
- **Coverage Report**: http://localhost:3000/coverage
- **Configuration**: http://localhost:3000/demo/configuration
- **Benchmarks**: http://localhost:3000/demo/benchmarks
- **Memory Profiling**: http://localhost:3000/demo/profiling

## Understanding Coverband Features

### Code Coverage

Navigate through the app (posts, books, demo pages) to generate coverage data. Then view the coverage report at `/coverage` to see:

- Which lines of code were executed
- Coverage percentages for each file
- Runtime vs test coverage comparison

### View Tracking

Enabled by default in this demo. Coverband tracks which views and partials are rendered. Check the coverage report to see view usage statistics.

**Configuration**: `config.track_views = true`

### Translation Tracking

This demo includes English and Spanish translations. Coverband tracks which I18n keys are actually used in your application.

**Configuration**: `config.track_translations = true`

**Try it**:
- Browse the demo pages to trigger translation key usage
- Check the coverage report for translation statistics

### Router Tracking

Monitors which routes are accessed in your application, helping you identify unused endpoints.

**Configuration**: `config.track_routes = true`

## Configuration Options

Coverband is highly configurable. This demo lets you test different configurations using environment variables.

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `COVERBAND_TRACK_VIEWS` | `true` | Enable/disable view tracking |
| `COVERBAND_TRACK_TRANSLATIONS` | `true` | Enable/disable translation tracking |
| `COVERBAND_TRACK_ROUTES` | `true` | Enable/disable route tracking |
| `COVERBAND_VERBOSE` | `false` | Enable verbose logging |
| `COVERBAND_HASH_STORE` | `false` | Use HashRedisStore for better performance |
| `COVERBAND_PAGER` | `false` | Enable paged reporting for large apps |
| `COVERBAND_DISABLE_AUTO_START` | `false` | Disable coverage collection (for benchmarking) |

### Example Configurations

**Minimal (Fastest Performance)**
```bash
COVERBAND_TRACK_VIEWS=false \
COVERBAND_TRACK_TRANSLATIONS=false \
COVERBAND_TRACK_ROUTES=false \
bundle exec rails s
```

**Full Tracking (Recommended for Development)**
```bash
COVERBAND_TRACK_VIEWS=true \
COVERBAND_TRACK_TRANSLATIONS=true \
COVERBAND_TRACK_ROUTES=true \
COVERBAND_VERBOSE=true \
bundle exec rails s
```

**Optimized for Large Applications**
```bash
COVERBAND_HASH_STORE=true \
COVERBAND_PAGER=true \
bundle exec rails s
```

## Storage Options

### Default Redis Store
Good for most applications. Stores coverage data in Redis sorted sets.

```ruby
# Automatically configured based on Redis URL
```

### HashRedisStore (Recommended for Production)
Better performance for applications with 1000+ files.

```bash
COVERBAND_HASH_STORE=true bundle exec rails s
```

### File Store
Store coverage locally without Redis (development only).

```ruby
# In config/coverband.rb
config.store = Coverband::Adapters::FileStore.new('/tmp/coverband_data')
```

## Performance Benchmarking

This demo includes comprehensive benchmarking tools.

### Coverage Report Performance

Measure how long it takes to generate the coverage page:

```bash
# Basic benchmark
COVERBAND_DISABLE_AUTO_START=true bundle exec rake coverband_benchmark

# With HashRedisStore
COVERBAND_DISABLE_AUTO_START=true COVERBAND_HASH_STORE=true bundle exec rake coverband_benchmark

# Single file detail view
COVERBAND_DISABLE_AUTO_START=true bundle exec rake coverband_benchmark_single_file
```

### Runtime Overhead

Measure the performance impact on your application:

```bash
# With Coverband
bundle exec rake runtime_overhead

# Without Coverband (for comparison)
COVERBAND_DISABLE_AUTO_START=true bundle exec rake runtime_overhead
```

### Scale Testing

Generate many files to test performance with large codebases:

```bash
# Generate 1000 test files
FILE_COUNT=1000 bundle exec rake generate_files

# Execute them to create coverage data
FILE_COUNT=1000 bundle exec rake execute_files

# Run benchmark
COVERBAND_DISABLE_AUTO_START=true bundle exec rake coverband_benchmark
```

### Network Latency Simulation

The benchmarks use [Toxiproxy](https://github.com/Shopify/toxiproxy) to simulate network latency:

```bash
# Install toxiproxy
brew install toxiproxy  # macOS

# Start toxiproxy
toxiproxy-server

# Run benchmarks (automatically applies latency)
bundle exec rake coverband_benchmark
```

## Memory Profiling

Understand Coverband's memory footprint and optimize usage.

### Memory Profile

Get current memory statistics:

```bash
bundle exec rake memory_profile
```

### Memory Comparison

Compare memory usage with and without Coverband:

```bash
# With Coverband
bundle exec rake memory_profile

# Without Coverband
COVERBAND_DISABLE_AUTO_START=true bundle exec rake memory_profile
```

### Request Memory Profile

Profile memory during simulated requests:

```bash
bundle exec rake memory_request_profile
```

### Redis Memory Usage

Check how much Redis memory Coverband is using:

```bash
bundle exec rake redis_memory_usage
```

## Testing

This demo includes a comprehensive test suite that serves dual purposes:
1. **Verify** the demo application works correctly
2. **Document** Coverband usage through executable examples

### Run All Tests

```bash
bundle exec rails test
```

### Run Coverband Documentation Tests Only

The `test/coverband/` directory contains tests that demonstrate how to use each Coverband feature:

```bash
# All Coverband feature tests
bundle exec rails test test/coverband/

# Specific feature tests
bundle exec rails test test/coverband/configuration_test.rb
bundle exec rails test test/coverband/view_tracking_test.rb
bundle exec rails test test/coverband/translation_tracking_test.rb
bundle exec rails test test/coverband/route_tracking_test.rb
bundle exec rails test test/coverband/storage_test.rb
bundle exec rails test test/coverband/integration_test.rb
bundle exec rails test test/coverband/performance_test.rb
bundle exec rails test test/coverband/configuration_scenarios_test.rb
```

### Test Suite Overview

| Test File | Purpose | Learn About |
|-----------|---------|-------------|
| `configuration_test.rb` | Basic configuration | How to configure Coverband |
| `view_tracking_test.rb` | View tracking | Tracking rendered views and partials |
| `translation_tracking_test.rb` | I18n tracking | Tracking translation key usage |
| `route_tracking_test.rb` | Route tracking | Monitoring endpoint access |
| `storage_test.rb` | Storage backends | RedisStore vs HashRedisStore vs FileStore |
| `integration_test.rb` | Complete workflows | Real-world usage scenarios |
| `performance_test.rb` | Performance impact | Measuring overhead and optimization |
| `configuration_scenarios_test.rb` | Real-world configs | Production, dev, API, etc. setups |

### Using Tests as Learning Resources

Each test file includes:
- Detailed comments explaining features
- Real-world use case examples
- Configuration code snippets
- Best practices and tips
- Common pitfalls and solutions

**Example**: To learn about view tracking:

```bash
# Read the test file for explanations
cat test/coverband/view_tracking_test.rb

# Run the tests to see it work
bundle exec rails test test/coverband/view_tracking_test.rb -v
```

See [TEST_DOCUMENTATION.md](TEST_DOCUMENTATION.md) for detailed information about the test suite and how to use it as living documentation.

### Run System Tests

```bash
bundle exec rails test:system
```

### Code Style and Quality

This demo uses RuboCop for code style enforcement:

```bash
# Check code style
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop --auto-correct-all
```

✅ **Status**: All tests passing (97 tests, 218 assertions), RuboCop clean (0 offenses)

See [TESTING_AND_STYLE.md](TESTING_AND_STYLE.md) for detailed information about testing and code style standards.

## Integrating Coverband Into Your App

### Step 1: Add to Gemfile

```ruby
gem 'coverband'
```

### Step 2: Install

```bash
bundle install
```

### Step 3: Configure

Create `config/coverband.rb`:

```ruby
Coverband.configure do |config|
  config.store = Coverband::Adapters::RedisStore.new(
    Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379')
  )

  # Optional: Enable additional tracking
  config.track_views = true
  config.track_translations = true
  config.track_routes = true

  # Production settings
  config.background_reporting_sleep_seconds = 300  # Report every 5 minutes
  config.reporting_wiggle = 30  # Random delay to avoid thundering herd
end
```

### Step 4: Mount Web Interface

In `config/routes.rb`:

```ruby
# Protect this route in production!
authenticate :user, lambda { |u| u.admin? } do
  mount Coverband::Reporters::Web.new, at: '/coverage'
end
```

### Step 5: Deploy and Monitor

Deploy your app and start collecting coverage data. Visit `/coverage` to view reports.

## Production Best Practices

### Performance Optimization

1. **Use HashRedisStore** for better performance with large codebases
2. **Increase reporting interval** to reduce overhead: `config.background_reporting_sleep_seconds = 300`
3. **Disable unused trackers** if you don't need them
4. **Ignore vendor code** to reduce tracking: `config.ignore = ['vendor/', 'node_modules/']`

### Memory Management

1. **Monitor Redis memory** usage regularly
2. **Clear old data** periodically: `Coverband.configuration.store.clear!`
3. **Use paged reporting** for large apps: `config.paged_reporting = true`

### Security

1. **Protect the web interface** with authentication
2. **Use environment-specific configs** to disable in test
3. **Monitor performance impact** in production

## Troubleshooting

### High Memory Usage

- Check how many files are being tracked
- Verify ignore patterns are working
- Consider using paged reporting
- Increase reporting interval

### Slow Coverage Reports

- Switch to HashRedisStore
- Enable paged reporting
- Clear old data
- Check Redis latency

### Missing Coverage Data

- Ensure Redis is running and accessible
- Check `background_reporting_sleep_seconds` setting
- Verify code is being executed
- Check for errors in Rails logs

## Additional Resources

- [Coverband GitHub Repository](https://github.com/danmayer/coverband)
- [Coverband Documentation](https://github.com/danmayer/coverband#coverband)
- [Coverage Report Demo](http://localhost:3000/coverage) (when running locally)

## Contributing

Issues and pull requests welcome! Please test your changes with this demo app before submitting.

## License

This demo application is MIT licensed. Coverband itself is also MIT licensed.

## Dependencies

- **Ruby**: 3.4.7
- **Rails**: 7.1.3
- **Redis**: 6.0+
- **Coverband**: Latest from `../coverband` (for development)

## Support

For questions or issues:

1. Check the [Coverband documentation](https://github.com/danmayer/coverband)
2. Review the [demo pages](http://localhost:3000/demo) for examples
3. Open an issue on the [Coverband repo](https://github.com/danmayer/coverband/issues)