source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

# rubocop:disable Bundler/OrderedGems
gem "debug"
gem "gem-ctags"
gem "rubocop"
gem "rubocop-erb", "~> 0.3"
gem "rubocop-minitest"
gem "rubocop-performance"
gem "rubocop-rails"
gem "rubocop-rake"
gem "rubocop-capybara", require: false

gem "guard"
gem "guard-bundler"
gem "guard-minitest"
gem "guard-rubocop"
gem "pg"
gem "redis"
gem "redlock"
gem "propshaft"
gem "puma"

group :test do
  gem "minitest"
  gem "minitest-reporters"
  gem "mocha"
  gem "webmock"

  gem "capybara"
  gem "selenium-webdriver"
end
# rubocop:enable Bundler/OrderedGems
