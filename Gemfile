source 'https://rubygems.org'
ruby "2.0.0"

gem 'rails', '~> 3.2.16'

gem 'google_drive'
gem 'google-spreadsheet-ruby'
gem 'roo', github: 'intridea/roo'

gem 'pg'

gem "therubyracer"
gem 'best_in_place'
gem 'redcarpet'
gem 'cocoon', '~> 1.2.5'

gem 'grape'
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'rack-google-analytics', :git => 'git://github.com/kangguru/rack-google-analytics.git', :branch => 'ga-js'
end

group :development do
  gem 'heroku'
  gem 'pry-rails'
end

group :test, :development do
  gem 'letter_opener'
  gem 'sqlite3', '~>1.3.5'
  gem "factory_girl_rails", "~> 4.0", require: false
  gem 'rspec-rails', '~> 2.0'
  gem 'watchr',  '~> 0.7'
  gem 'spork', '~> 1.0rc'

  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-yard'
  gem 'shoulda-matchers'
end

group :test do
  gem 'rack-test', git: "git://github.com/brynary/rack-test.git"
  gem 'simplecov', require: false

  gem 'vcr',     '~> 2.8.0'
  gem 'webmock', '~> 1.15.0'
end

gem 'loadjs'
gem 'jquery-rails'
gem 'bootstrap-datepicker-rails'
gem 'delayed_job_active_record'
gem "daemons"
gem "rails-settings-cached", '~> 0.2.4'

# To use Jbuilder templates for JSON
gem 'jbuilder'
gem 'grape-jbuilder'

# Use unicorn as the web server
gem 'unicorn'

gem "omniauth"
gem "omniauth-google-oauth2", "~> 0.1.17"

gem "acts_as_paranoid", "~>0.4.0"

gem 'paper_trail', '>= 3.0.0.rc1'

# confluence integration
gem 'confluence-soap'

group :linux_development do
  gem 'rb-inotify'
  gem 'libnotify'
end

group :mac_development do
  gem 'rb-fsevent'
end

gem 'cancan'
gem 'rest-client'
