# Test Documentation - Coverband Rails Demo

This test suite serves dual purposes:
1. **Verify** that the demo application works correctly
2. **Document** how to use and configure Coverband through executable examples

## Test Organization

### Application Tests

Standard Rails tests that verify the demo app functionality:

- `test/controllers/demo_controller_test.rb` - Demo pages functionality
- `test/controllers/posts_controller_test.rb` - Posts CRUD operations
- `test/controllers/books_controller_test.rb` - Books CRUD operations
- `test/models/` - Model validations and behavior
- `test/system/` - End-to-end browser tests

### Coverband Documentation Tests

Living documentation tests in `test/coverband/` that demonstrate Coverband usage:

#### 1. Configuration Tests (`configuration_test.rb`)

**Purpose**: Show how to configure Coverband and access configuration settings

**Key Examples**:
- How to verify Coverband is configured
- How to check which storage backend is being used
- How to enable/disable tracking features
- How to access configuration values programmatically

**Run**: `bundle exec rails test test/coverband/configuration_test.rb`

#### 2. View Tracking Tests (`view_tracking_test.rb`)

**Purpose**: Demonstrate view tracking feature and its usage

**Key Examples**:
- How to enable view tracking
- How views and partials are tracked
- How to identify unused views
- How to disable view tracking for performance

**Run**: `bundle exec rails test test/coverband/view_tracking_test.rb`

**Real-World Use Case**: Find and remove unused view files to reduce codebase size

#### 3. Translation Tracking Tests (`translation_tracking_test.rb`)

**Purpose**: Show how translation tracking works with I18n

**Key Examples**:
- How to track I18n key usage
- How to work with multiple locales
- How to find unused translation keys
- How nested translation keys are tracked

**Run**: `bundle exec rails test test/coverband/translation_tracking_test.rb`

**Real-World Use Case**: Clean up locale files by removing unused translation keys

#### 4. Route Tracking Tests (`route_tracking_test.rb`)

**Purpose**: Demonstrate route tracking and endpoint monitoring

**Key Examples**:
- How to track GET, POST, PATCH, DELETE requests
- How RESTful routes are tracked
- How to identify unused API endpoints
- How routes with parameters are tracked

**Run**: `bundle exec rails test test/coverband/route_tracking_test.rb`

**Real-World Use Case**: Identify and deprecate unused API endpoints

#### 5. Storage Tests (`storage_test.rb`)

**Purpose**: Document storage backend options and usage

**Key Examples**:
- How to access the storage backend
- Required storage interface methods
- How to clear coverage data
- Differences between RedisStore and HashRedisStore

**Run**: `bundle exec rails test test/coverband/storage_test.rb`

**Real-World Use Case**: Choose the right storage backend for your application size

#### 6. Integration Tests (`integration_test.rb`)

**Purpose**: Show complete workflows using multiple features together

**Key Examples**:
- Complete user journey tracking
- CRUD operations tracking
- Dead code identification workflow
- Multi-resource tracking
- Error path tracking
- Background job coverage

**Run**: `bundle exec rails test test/coverband/integration_test.rb`

**Real-World Use Case**: Understanding how all Coverband features work together

#### 7. Performance Tests (`performance_test.rb`)

**Purpose**: Demonstrate how to measure Coverband's performance impact

**Key Examples**:
- How to measure request overhead
- How to compare tracking configurations
- How to measure memory usage
- How to benchmark different settings

**Run**: `bundle exec rails test test/coverband/performance_test.rb`

**Real-World Use Case**: Optimize Coverband configuration for your performance requirements

#### 8. Configuration Scenarios Tests (`configuration_scenarios_test.rb`)

**Purpose**: Show real-world configuration patterns for different use cases

**Key Examples**:
- Development environment setup
- Production optimization
- API-only application config
- Dead code identification setup
- High-performance configuration
- Security audit setup

**Run**: `bundle exec rails test test/coverband/configuration_scenarios_test.rb`

**Real-World Use Case**: Choose the right configuration for your specific needs

## Running Tests

### Run All Tests

```bash
bundle exec rails test
```

### Run Only Coverband Documentation Tests

```bash
bundle exec rails test test/coverband/
```

### Run Specific Test File

```bash
bundle exec rails test test/coverband/configuration_test.rb
```

### Run Specific Test

```bash
bundle exec rails test test/coverband/configuration_test.rb:10
```

### Run Tests with Verbose Output

```bash
bundle exec rails test -v
```

## Using Tests as Documentation

### Example 1: Learning View Tracking

1. Open `test/coverband/view_tracking_test.rb`
2. Read the test descriptions and comments
3. Run the tests: `bundle exec rails test test/coverband/view_tracking_test.rb`
4. Try the examples in your own code
5. Modify tests to experiment with different scenarios

### Example 2: Configuring for Production

1. Open `test/coverband/configuration_scenarios_test.rb`
2. Find the "production environment standard configuration" test
3. Read the configuration and comments
4. Apply similar configuration to your `config/coverband.rb`
5. Run tests to verify behavior

### Example 3: Measuring Performance

1. Open `test/coverband/performance_test.rb`
2. Read the performance measurement examples
3. Run: `bundle exec rails test test/coverband/performance_test.rb -v`
4. Note the output showing timing and memory stats
5. Use similar techniques in your application

## Test Patterns and Conventions

### Setup/Teardown Pattern

Most Coverband tests use setup/teardown to preserve configuration:

```ruby
setup do
  @original_track_views = Coverband.configuration.track_views
  Coverband.configuration.track_views = true
end

teardown do
  Coverband.configuration.track_views = @original_track_views
end
```

This ensures tests don't affect each other.

### Documentation Comments

Tests include extensive comments explaining:
- What the test demonstrates
- How the feature works
- Real-world use cases
- Expected behavior
- Related workflows

### Assertion Messages

Assertions include descriptive messages:

```ruby
assert Coverband.configuration.track_views,
       "View tracking should be enabled for these tests"
```

This makes test failures self-documenting.

## Testing Your Own Coverband Integration

Use these tests as templates for testing your own Coverband setup:

### 1. Copy Relevant Tests

Copy the test files that match your use case to your application.

### 2. Adapt to Your Configuration

Modify the tests to match your specific configuration needs.

### 3. Add Application-Specific Tests

Add tests for your specific tracking requirements.

### 4. Run Regularly

Include in CI/CD to ensure configuration stays correct.

## Common Test Scenarios

### Scenario: Verify Tracking is Working

```ruby
test "my feature is tracked" do
  # Perform action
  get my_feature_path

  # Verify it worked
  assert_response :success

  # Note: Actual coverage data verification would require
  # inspecting Coverband.configuration.store.coverage
end
```

### Scenario: Test Configuration Change

```ruby
test "disabling tracking improves performance" do
  Coverband.configuration.track_views = true
  slow_time = measure_request_time

  Coverband.configuration.track_views = false
  fast_time = measure_request_time

  assert fast_time < slow_time, "Should be faster with tracking disabled"
end
```

### Scenario: Verify Storage Backend

```ruby
test "using correct storage backend" do
  store_class = Coverband.configuration.store.class.name

  assert_equal "Coverband::Adapters::HashRedisStore", store_class,
               "Production should use HashRedisStore"
end
```

## Debugging Tests

### Enable Verbose Output

```bash
bundle exec rails test test/coverband/configuration_test.rb -v
```

### Run Single Test

```bash
bundle exec rails test test/coverband/configuration_test.rb:8
```

### Add Debug Output

```ruby
test "something" do
  puts "Configuration: #{Coverband.configuration.inspect}"
  # ... test code ...
end
```

### Use Rails Console for Exploration

```bash
bundle exec rails console
> Coverband.configuration.track_views
> Coverband.configuration.store.class.name
```

## Contributing Tests

When adding new tests to this demo:

1. **Document the purpose** - Explain what the test demonstrates
2. **Add real-world context** - Show why someone would need this
3. **Include examples** - Provide code snippets in comments
4. **Be descriptive** - Use clear test names and assertion messages
5. **Follow patterns** - Match the style of existing tests

## Test Coverage

Run SimpleCov to see test coverage:

```bash
COVERAGE=true bundle exec rails test
open coverage/index.html
```

This demo aims for high test coverage to ensure all features are documented and verified.

## Additional Resources

- [Coverband GitHub](https://github.com/danmayer/coverband) - Main documentation
- [Demo README](README.md) - Getting started guide
- [Demo Usage](USAGE.md) - Step-by-step walkthrough
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html) - Rails testing basics

## Questions and Support

If you have questions about:
- **These tests**: Open an issue on the demo repo
- **Coverband usage**: Open an issue on the main Coverband repo
- **General testing**: Refer to the Rails Testing Guide

Remember: These tests are living documentation. They should always run successfully and accurately demonstrate Coverband's features and usage patterns.
