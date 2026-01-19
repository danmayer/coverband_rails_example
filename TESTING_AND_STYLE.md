# Testing and Style Guide

This document outlines the testing strategy and code style standards for the Coverband Rails Demo.

## Test Suite Status

✅ **All tests passing**: 97 tests, 218 assertions, 0 failures, 0 errors

### Test Breakdown

- **8 Coverband documentation tests** - Living documentation demonstrating features
- **3 Controller tests** - Demo, Posts, Books controllers
- **2 Model tests** - Post and Book models
- **2 System tests** - End-to-end browser testing

## Running Tests

### Run All Tests

```bash
bundle exec rails test
```

### Run Specific Test Suites

```bash
# Coverband documentation tests only
bundle exec rails test test/coverband/

# Controller tests
bundle exec rails test test/controllers/

# Model tests
bundle exec rails test test/models/

# System tests
bundle exec rails test:system

# Specific test file
bundle exec rails test test/coverband/configuration_test.rb

# Specific test
bundle exec rails test test/coverband/configuration_test.rb:10
```

### Verbose Output

```bash
bundle exec rails test -v
```

## Code Style with RuboCop

✅ **RuboCop clean**: 46 files inspected, 0 offenses detected

### Running RuboCop

```bash
# Check all files
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop --auto-correct-all

# Check specific file
bundle exec rubocop app/controllers/demo_controller.rb

# Show offense counts
bundle exec rubocop --format offenses
```

### RuboCop Configuration

Configuration is in `.rubocop.yml` with the following key settings:

- **Target Ruby Version**: 3.4
- **Line Length**: 120 characters (140 for tests and views)
- **String Style**: Double quotes preferred
- **Documentation**: Disabled (extensive inline comments instead)
- **Frozen String Literals**: Disabled (not critical for demo)

### Exclusions

The following are excluded from certain checks for demo purposes:

- **Metrics checks**: Excluded for `test/`, `Rakefile`, `demo_controller.rb`
- **Documentation cop**: Disabled globally (inline docs are comprehensive)
- **Rails I18n warnings**: Excluded for scaffold-generated messages
- **Security/Eval**: Allowed in Rakefile for test file generation

## Test Coverage

Tests serve dual purposes:

1. **Verification** - Ensure the demo app works correctly
2. **Documentation** - Demonstrate how to use Coverband features

### Coverage Test Files

| File | Purpose | Lines |
|------|---------|-------|
| `configuration_test.rb` | Basic configuration and setup | ~100 |
| `view_tracking_test.rb` | View and partial tracking | ~150 |
| `translation_tracking_test.rb` | I18n key tracking | ~180 |
| `route_tracking_test.rb` | Route and endpoint monitoring | ~250 |
| `storage_test.rb` | Storage backend options | ~150 |
| `integration_test.rb` | Complete workflows | ~300 |
| `performance_test.rb` | Performance measurement | ~250 |
| `configuration_scenarios_test.rb` | Real-world configs | ~350 |

## Testing Best Practices

### 1. Setup/Teardown Pattern

Tests preserve and restore configuration:

```ruby
setup do
  @original_track_views = Coverband.configuration.track_views
  Coverband.configuration.track_views = true
end

teardown do
  Coverband.configuration.track_views = @original_track_views
end
```

### 2. Descriptive Test Names

Use clear, descriptive test names:

```ruby
test "view tracking should be enabled when configured" do
  # ...
end
```

### 3. Inline Documentation

Tests include extensive comments:

```ruby
# Test: View tracking is enabled
# Demonstrates how to check if view tracking is active
test "view tracking should be enabled when configured" do
  # ...
end
```

### 4. Assertion Messages

Include helpful assertion messages:

```ruby
assert Coverband.configuration.track_views,
       "View tracking should be enabled for these tests"
```

## Code Style Guidelines

### String Literals

Use double quotes:

```ruby
# Good
puts "Hello world"

# Avoid
puts 'Hello world'
```

### Hash Syntax

Prefer modern syntax, allow either:

```ruby
# Both acceptable
{ key: "value" }
{ "key" => "value" }
```

### Trailing Commas

Use trailing commas in multiline structures:

```ruby
config = {
  track_views: true,
  track_translations: true,
  track_routes: true,
}
```

### Line Length

Keep lines under 120 characters. Split long lines:

```ruby
# Good
long_variable = some_long_method_call(
  parameter1,
  parameter2,
)

# Avoid
long_variable = some_long_method_call(parameter1, parameter2, parameter3, parameter4)
```

### Method Complexity

Keep methods simple. Demo controllers are exempt for demonstration purposes:

```ruby
# Acceptable in demo_controller.rb
def configuration
  # Complex method showing many config options
end

# In regular code, prefer simpler methods
def show
  @post = Post.find(params[:id])
end
```

## Continuous Integration

For CI/CD pipelines, run both tests and style checks:

```bash
# In CI script
bundle exec rails test
bundle exec rubocop
```

## Pre-commit Hooks

Consider using a pre-commit hook to run RuboCop:

```bash
# .git/hooks/pre-commit
#!/bin/sh
bundle exec rubocop --fail-level E
```

## Common Issues and Solutions

### Issue: Tests fail after code changes

**Solution**: Ensure configuration is properly restored in teardown

### Issue: RuboCop offenses after adding new code

**Solution**: Run `bundle exec rubocop --auto-correct-all` first

### Issue: Long lines in documentation

**Solution**: Break into multiple lines or add to exclusions if necessary

### Issue: Metrics violations in tests

**Solution**: Tests are exempt from metrics checks via `.rubocop.yml`

## Documentation

- **Test Documentation**: See [TEST_DOCUMENTATION.md](TEST_DOCUMENTATION.md)
- **Usage Guide**: See [USAGE.md](USAGE.md)
- **Main README**: See [README.md](README.md)

## Contributing

When adding new code:

1. Write tests first (TDD)
2. Run tests: `bundle exec rails test`
3. Run RuboCop: `bundle exec rubocop --auto-correct-all`
4. Fix remaining offenses manually
5. Ensure all tests pass
6. Document in comments

## Quick Reference

```bash
# Full test and style check
bundle exec rails test && bundle exec rubocop

# Auto-fix and test
bundle exec rubocop --auto-correct-all && bundle exec rails test

# Specific feature test
bundle exec rails test test/coverband/view_tracking_test.rb -v

# Check specific file style
bundle exec rubocop app/controllers/demo_controller.rb
```

## Status

✅ All tests passing
✅ RuboCop clean
✅ Documentation comprehensive
✅ Ready for use as learning resource
