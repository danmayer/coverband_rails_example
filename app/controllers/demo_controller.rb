class DemoController < ApplicationController
  def index
    # Home page showing all features
  end

  def configuration
    # Show current Coverband configuration
    @current_config = {
      track_views: Coverband.configuration.track_views,
      track_translations: Coverband.configuration.track_translations,
      track_routes: Coverband.configuration.track_routes,
      verbose: Coverband.configuration.verbose,
      store_type: Coverband.configuration.store.class.name,
      background_reporting_sleep_seconds: Coverband.configuration.background_reporting_sleep_seconds,
      web_enable_clear: Coverband.configuration.web_enable_clear,
      reporting_wiggle: Coverband.configuration.reporting_wiggle,
    }

    # Environment variables that can be used to configure Coverband
    @env_configs = [
      { name: "COVERBAND_TRACK_VIEWS", description: "Enable/disable view tracking",
        current_value: ENV["COVERBAND_TRACK_VIEWS"] || "true" },
      { name: "COVERBAND_TRACK_TRANSLATIONS", description: "Enable/disable translation tracking",
        current_value: ENV["COVERBAND_TRACK_TRANSLATIONS"] || "true" },
      { name: "COVERBAND_TRACK_ROUTES", description: "Enable/disable route tracking",
        current_value: ENV["COVERBAND_TRACK_ROUTES"] || "true" },
      { name: "COVERBAND_VERBOSE", description: "Enable verbose logging",
        current_value: ENV["COVERBAND_VERBOSE"] || "false" },
      { name: "COVERBAND_HASH_STORE", description: "Use HashRedisStore instead of default",
        current_value: ENV["COVERBAND_HASH_STORE"] || "false" },
      { name: "COVERBAND_PAGER", description: "Enable paged reporting in web interface",
        current_value: ENV["COVERBAND_PAGER"] || "false" },
      { name: "COVERBAND_DISABLE_AUTO_START", description: "Disable automatic coverage collection",
        current_value: ENV["COVERBAND_DISABLE_AUTO_START"] || "false" },
    ]
  end

  def benchmarks
    # Show available benchmarks and how to run them
  end

  def profiling
    # Show memory usage and profiling information
    require "objspace"

    @memory_stats = {
      total_objects: ObjectSpace.count_objects[:TOTAL],
      free_objects: ObjectSpace.count_objects[:FREE],
      strings: ObjectSpace.count_objects[:T_STRING],
      arrays: ObjectSpace.count_objects[:T_ARRAY],
      hashes: ObjectSpace.count_objects[:T_HASH],
    }

    # Get process memory info if available
    if File.exist?("/proc/#{Process.pid}/status")
      status = File.read("/proc/#{Process.pid}/status")
      @memory_stats[:vm_size] = status[/VmSize:\s+(\d+)/, 1]&.to_i
      @memory_stats[:vm_rss] = status[/VmRSS:\s+(\d+)/, 1]&.to_i
    end

    # Coverband-specific memory info
    @coverband_stats = {}
    return unless Coverband.configuration.store.respond_to?(:coverage)

    begin
      @coverband_stats[:tracked_files] = Coverband.configuration.store.coverage.keys.length
    rescue StandardError
      @coverband_stats[:tracked_files] = 0
    end
  end
end
