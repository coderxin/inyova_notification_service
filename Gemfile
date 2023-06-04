# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'rails', '~> 7.0.5'

gem 'pg', '~> 1.5.3'

gem 'puma', '~> 5.0'

gem 'jbuilder', '~> 2.11.5'

gem 'bcrypt', '~> 3.1.7'

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'bootsnap', require: false

gem 'aasm', '~> 5.5'

gem 'jwt_sessions', '~> 3.1.1'

gem 'redis', '~> 5.0.6'

gem 'sidekiq', '~> 7.1'

gem 'mock_push_service', '~> 0.1.0'

group :development, :test do
  gem 'awesome_print'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  gem 'guard-rspec', require: false
end

group :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers', '~> 5.0'
end
