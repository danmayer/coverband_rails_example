# Coverband Rails Demo

It has been awhile since I built and hosted a Coverband Rails example app. This demo is intended to show how to get up and running with Coverband and some of the various configuration options.

* See the [Coverband Repo](https://github.com/danmayer/coverband) for documentation and more details

# Getting Started

* `git clone git@github.com:danmayer/coverband_rails_example.git`
* `bundle install`
* `bundle exec rails s`
* open: http://localhost:3000/coverage

# Demo Dependencies

* built with Rails 7.1
* Ruby 3.2.2

# Deploy to Render

This application is configured to be easily deployed on [Render.com](https://render.com).

1.  Fork this repository.
2.  Create a new Web Service on Render.
3.  Connect your GitHub account and select your forked repository.
4.  Render will automatically detect the `render.yaml` blueprint (or you can select "Docker" as the runtime).
5.  **Important:** Coverband requires Redis. Render does not offer a free Redis instance that persists.
    *   Sign up for a free Redis instance at [Upstash](https://upstash.com/) or [Redis Cloud](https://redis.com/try-free/).
    *   Get your Redis connection URL. **Note:** Ensure the URL includes the username and password in the format `redis://user:password@host:port`.
        *   Example: `redis://default:abc123456@fly-foo-bar.upstash.io:6379`
    *   In the Render dashboard for your service, add an Environment Variable named `REDIS_URL` with your connection string.

# How to run the test suite

* `bundle exec rake`