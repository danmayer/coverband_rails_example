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
###
desc "Benchmark the performance of the Coverband coverage page"
task coverband_benchmark: :environment do
    Coverband.configure
    data = Benchmark.measure do
        Coverband::Reporters::Web.new.tap do |cov|
            cov.instance_variable_set(:@request,Rack::Request.new(Rack::MockRequest.env_for("/")))
        end.index
    end
    puts data
end

###
# Test against:
# * gzip original set get
# * use toxiproxy to add latency and simulate remote redis
# * look at a paging solution for the web interface
###

desc "generate a bunch of files to show impact of various project file counts"
task generate_files: :environment do
    (ENV["FILE_COUNT"] || 1000).to_i.times do |i|
        file_content = <<TEXT
class Generated#{i} < ApplicationRecord
    def self.bark
        "woof"
    end
end
TEXT

        File.open("app/models/generated_#{i}.rb", "w") do |f|
            f.write(file_content)
        end
    end
end

desc "ensure all the generated files are loaded and executed creating coverage data"
task execute_files: :environment do
    (ENV["FILE_COUNT"] || 1000).to_i.times do |i|
        eval "Generated#{i}.bark"
    end
    nil
end