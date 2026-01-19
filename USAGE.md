# Coverband Demo Usage Guide

This guide walks you through exploring all of Coverband's features using this demo application.

## Initial Setup

1. **Start Redis**
   ```bash
   redis-server
   ```

2. **Setup the database**
   ```bash
   bundle exec rails db:create
   bundle exec rails db:migrate
   bundle exec rails db:seed
   ```

3. **Start the application**
   ```bash
   bundle exec rails server
   ```

4. **Open in browser**
   - Navigate to http://localhost:3000

## Exploring Code Coverage

### Generate Some Coverage Data

1. Visit the demo home page: http://localhost:3000
2. Navigate through posts and books:
   - Click "Posts" in the navigation
   - Click "Books" in the navigation
   - View some individual posts and books
3. Create a new post or book
4. Edit an existing record

### View Coverage Report

1. Click "Coverage Report" in the navigation (or visit http://localhost:3000/coverage)
2. Observe:
   - Which files were executed
   - Coverage percentages
   - Line-by-line coverage details
   - Click on any file to see detailed coverage

### Understanding the Coverage Colors

- **Green lines**: Code that was executed
- **Red lines**: Code that was not executed
- **Gray lines**: Non-executable lines (comments, blank lines)

## Exploring View Tracking

View tracking is enabled by default in this demo.

1. **Generate view data** by navigating through the app:
   - Visit posts index
   - View a specific post
   - Edit a post
   - Do the same for books

2. **Check tracked views** in the coverage report:
   - Look for view files (`.erb` files) in the coverage report
   - See which views and partials were rendered
   - Identify unused views

## Exploring Translation Tracking

This demo includes both English and Spanish translations.

1. **Check current translations** in use:
   - The navigation uses translations (`t('app.navigation.home')`, etc.)
   - Posts and books pages use translations
   - Look at `config/locales/en.yml` and `config/locales/es.yml`

2. **Generate translation usage data**:
   - Navigate through the app (every page uses some translations)
   - Check the coverage report for translation key usage

3. **Find unused translations**:
   - Some translation keys in the locale files may not be used
   - Coverband will show which keys are actually accessed

## Exploring Router Tracking

Router tracking monitors which routes are accessed.

1. **Access different routes**:
   - Visit posts index (`GET /posts`)
   - View a post (`GET /posts/:id`)
   - Create a new post (`GET /posts/new`, `POST /posts`)
   - Edit a post (`GET /posts/:id/edit`, `PATCH /posts/:id`)
   - Same for books

2. **View route usage**:
   - Check the coverage report for route access patterns
   - Identify which routes are not being used

## Testing Different Configurations

### Minimal Configuration (Maximum Performance)

```bash
COVERBAND_TRACK_VIEWS=false \
COVERBAND_TRACK_TRANSLATIONS=false \
COVERBAND_TRACK_ROUTES=false \
bundle exec rails server
```

Then navigate through the app and notice faster response times.

### Full Tracking Configuration

```bash
COVERBAND_TRACK_VIEWS=true \
COVERBAND_TRACK_TRANSLATIONS=true \
COVERBAND_TRACK_ROUTES=true \
COVERBAND_VERBOSE=true \
bundle exec rails server
```

Check the logs to see verbose output about what Coverband is tracking.

### HashRedisStore (Better Performance)

```bash
COVERBAND_HASH_STORE=true \
bundle exec rails server
```

This provides better performance for larger applications.

## Running Benchmarks

### Basic Coverage Report Benchmark

```bash
# First, generate some coverage data by using the app
bundle exec rails server
# (Navigate through the app in your browser)
# Then stop the server (Ctrl+C) and run:

COVERBAND_DISABLE_AUTO_START=true bundle exec rake coverband_benchmark
```

This shows how long it takes to generate the coverage report.

### Compare Storage Backends

```bash
# Default store
COVERBAND_DISABLE_AUTO_START=true bundle exec rake coverband_benchmark

# HashRedisStore
COVERBAND_DISABLE_AUTO_START=true COVERBAND_HASH_STORE=true bundle exec rake coverband_benchmark
```

### Runtime Overhead Benchmark

```bash
# With Coverband
bundle exec rake runtime_overhead

# Without Coverband (for comparison)
COVERBAND_DISABLE_AUTO_START=true bundle exec rake runtime_overhead
```

### Scale Testing

Test how Coverband performs with a large codebase:

```bash
# Generate 1000 files
FILE_COUNT=1000 bundle exec rake generate_files

# Execute them to create coverage
FILE_COUNT=1000 bundle exec rake execute_files

# Benchmark the report
COVERBAND_DISABLE_AUTO_START=true bundle exec rake coverband_benchmark

# View in browser
bundle exec rails server
# Visit http://localhost:3000/coverage

# Clean up when done
rm app/models/generated_*.rb
```

## Memory Profiling

### Check Current Memory Usage

```bash
bundle exec rake memory_profile
```

This shows:
- Ruby object counts
- Process memory (RSS)
- Coverband-specific stats

### Compare With and Without Coverband

```bash
# With Coverband
bundle exec rake memory_profile

# Without Coverband
COVERBAND_DISABLE_AUTO_START=true bundle exec rake memory_profile
```

### Profile Memory During Requests

```bash
bundle exec rake memory_request_profile
```

This simulates application work and measures memory changes.

### Check Redis Memory Usage

```bash
bundle exec rake redis_memory_usage
```

Shows how much Redis memory Coverband is using.

## Using the Configuration Dashboard

Visit http://localhost:3000/demo/configuration to:

- View current Coverband settings
- See all available environment variables
- Learn about different storage options
- Copy example configurations

## Clearing Coverage Data

To start fresh:

1. **Via Web Interface**:
   - Visit http://localhost:3000/coverage
   - Click the "Clear Coverage" button (if enabled in config)

2. **Via Rails Console**:
   ```bash
   bundle exec rails console
   Coverband.configuration.store.clear!
   ```

3. **Via Redis CLI**:
   ```bash
   redis-cli
   FLUSHDB  # Clears all keys in current database
   ```

## Best Practices for Demo Exploration

1. **Start with clean data**:
   - Clear coverage before each test
   - Run seeds to get consistent data

2. **Test one feature at a time**:
   - Enable only the feature you're testing
   - Compare with feature disabled

3. **Use verbose mode for learning**:
   - Run with `COVERBAND_VERBOSE=true` to see what's happening
   - Check Rails logs for detailed information

4. **Benchmark before optimizing**:
   - Always measure baseline performance first
   - Test one optimization at a time

5. **Monitor Redis**:
   - Keep an eye on Redis memory usage
   - Clear old data regularly during testing

## Troubleshooting

### No Coverage Data Showing

- Ensure Redis is running: `redis-cli ping`
- Check that Coverband is not disabled: No `COVERBAND_DISABLE_AUTO_START` env var
- Wait for background reporting (10 seconds by default)
- Check Rails logs for errors

### Coverage Report is Slow

- Try HashRedisStore: `COVERBAND_HASH_STORE=true`
- Enable paging: `COVERBAND_PAGER=true`
- Clear old data: Visit `/coverage` and click "Clear"

### High Memory Usage

- Check how many files are tracked: `bundle exec rake memory_profile`
- Verify ignore patterns are working
- Increase `background_reporting_sleep_seconds`

## Next Steps

After exploring this demo:

1. Review the [main documentation](https://github.com/danmayer/coverband)
2. Try integrating Coverband into your own Rails app
3. Experiment with different configurations for your use case
4. Set up monitoring and alerting for production use

## Need Help?

- Check the [README](README.md) for detailed documentation
- Visit the [Coverband GitHub repo](https://github.com/danmayer/coverband)
- Open an issue if you find problems
