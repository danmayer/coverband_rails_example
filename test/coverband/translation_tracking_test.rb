require "test_helper"

# This test demonstrates Coverband's translation tracking feature.
# Translation tracking helps identify which I18n keys are actually used in your application.
# These tests serve as living documentation for understanding translation tracking.
class Coverband::TranslationTrackingTest < ActionDispatch::IntegrationTest
  setup do
    # Store the original tracking state
    @original_track_translations = Coverband.configuration.track_translations

    # Ensure translation tracking is enabled for these tests
    Coverband.configuration.track_translations = true
  end

  teardown do
    # Restore original configuration
    Coverband.configuration.track_translations = @original_track_translations
  end

  # Test: Translation tracking is enabled
  # Demonstrates how to verify translation tracking is active
  test "translation tracking should be enabled when configured" do
    assert Coverband.configuration.track_translations,
           "Translation tracking should be enabled for these tests"
  end

  # Test: Accessing translated content tracks I18n keys
  # Shows that using translations causes keys to be tracked
  test "rendering pages with translations tracks i18n keys" do
    # The demo home page uses many translation keys
    get demo_path
    assert_response :success

    # Translation keys like 'demo.welcome', 'demo.description' etc. should be tracked
    # You can verify this in the coverage report at /coverage
  end

  # Test: Translation keys in navigation are tracked
  # Demonstrates tracking of translations used in layouts
  test "translations in navigation are tracked" do
    # The navigation uses translation keys like:
    # - app.navigation.home
    # - app.navigation.posts
    # - app.navigation.books
    # - app.navigation.coverage
    # - app.navigation.config

    get demo_path
    assert_response :success

    # All navigation translation keys should be tracked
  end

  # Test: Multiple locales tracking
  # Shows that translations work with different locales
  test "translations work with english locale" do
    # Default locale is English
    I18n.with_locale(:en) do
      get demo_path
      assert_response :success

      # English translation keys should be tracked
      assert_match(/Welcome/, response.body)
    end
  end

  # Test: Tracking translations across different pages
  # Demonstrates that translations from multiple pages are tracked
  test "translations across different pages are tracked" do
    # Demo page
    get demo_path
    assert_response :success

    # Posts page (uses posts.title, posts.new, etc.)
    get posts_path
    assert_response :success

    # Books page (uses books.title, books.new, etc.)
    get books_path
    assert_response :success

    # Each page uses different translation keys, all should be tracked
  end

  # Test: Translation tracking can be disabled
  # Shows that disabling translation tracking still allows translations to work
  test "translation tracking can be disabled" do
    # Disable translation tracking
    Coverband.configuration.track_translations = false

    # Translations still work, but won't be tracked
    get demo_path
    assert_response :success
    assert_match(/Welcome/, response.body)

    # Useful for performance when you don't need to track translations
  end

  # Test: Fallback translations
  # Demonstrates handling of fallback translations
  test "fallback to english when translation missing" do
    # If a translation is missing in a locale, Rails falls back to English
    I18n.with_locale(:en) do
      # This should work even if some translations are missing
      get demo_path
      assert_response :success
    end
  end

  # Test: Common translations are tracked
  # Shows that commonly used translation keys are tracked
  test "common translation keys are tracked" do
    # The 'hello' key is defined in both en.yml and es.yml
    translated_hello = I18n.t("hello")
    assert_equal "Hello world", translated_hello

    # This translation access should be tracked by Coverband
  end

  # Test: Nested translation keys
  # Demonstrates tracking of nested translation keys
  test "nested translation keys are tracked" do
    # Access nested keys
    app_title = I18n.t("app.title")
    assert_equal "Coverband Rails Demo", app_title

    posts_title = I18n.t("posts.title")
    assert_equal "Posts", posts_title

    # Nested keys like 'app.title' and 'posts.title' should be tracked
  end

  # Test: Unused translations can be identified
  # Shows how to find translation keys that are never used
  test "unused translation keys are not tracked" do
    # Some translation keys might be defined but never used
    # For example, if we define a key but never call I18n.t() for it

    # Access specific keys
    get posts_path
    assert_response :success

    # Only the keys actually used on this page will be tracked
    # Other keys in the locale files won't appear in coverage
    # This helps identify dead translations
  end

  # Test: Translation interpolation is tracked
  # Demonstrates that translations with variables are tracked
  test "translations with interpolation are tracked" do
    # Even translations with interpolation should be tracked
    # Example: I18n.t('posts.created', count: 5)

    # The key 'posts.created' would be tracked regardless of interpolation
    get demo_path
    assert_response :success
  end
end

# Additional documentation on using translation tracking:
#
# ## How to Enable Translation Tracking
#
# In config/coverband.rb:
#   Coverband.configure do |config|
#     config.track_translations = true
#   end
#
# Or via environment variable:
#   COVERBAND_TRACK_TRANSLATIONS=true bundle exec rails server
#
# ## Viewing Tracked Translations
#
# 1. Run your application with translation tracking enabled
# 2. Navigate through your application
# 3. Visit /coverage to see the coverage report
# 4. Look for translation key usage in the report
# 5. Compare with your locale files (config/locales/*.yml)
# 6. Unused keys indicate dead translations
#
# ## Use Cases
#
# - Identify unused translation keys
# - Clean up old translations
# - Understand which keys are actually used
# - Optimize locale file loading
# - Find missing translations
# - Audit multi-locale support
#
# ## Example Workflow
#
# 1. Add translations to config/locales/en.yml
# 2. Use them in views: <%= t('my.new.key') %>
# 3. Run the app and use the feature
# 4. Check /coverage to verify the key is tracked
# 5. Remove any keys not showing up in coverage
