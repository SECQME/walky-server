source 'https://rubygems.org'

gem 'rails', '4.2.3'
gem 'rgeo-activerecord', '~> 4.0'
gem 'rgeo-geojson', '~> 0.3.1'
gem 'rgeo', '~> 0.5'
gem 'activerecord-postgis-adapter', '~> 3.0'
gem 'pg', '0.18.3'

gem 'rack-cors', '~> 0.4.0', :require => 'rack/cors'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

gem 'jquery-rails'
gem 'turbolinks'

gem 'rabl-rails'

gem 'rollbar', '~> 2.4.0'
gem 'oj', '~> 2.12.14'

gem 'passenger'
gem 'lograge'
gem 'responders', '~> 2.0'

gem 'recursive-open-struct'
gem 'polylines', '~> 0.3.0'
gem 'gmaps4rails', '~> 2.1.2'
gem 'httparty', '~> 0.13.5'
gem 'graticule', '~> 2.5.0'
gem 'will_paginate', '~> 3.0.7'

gem 'aws-sdk', '~> 2'
gem 'redis', '~> 3.2'
gem 'connection_pool', '~> 2.2'

gem "refile", require: "refile/rails"
gem "refile-mini_magick"

gem 'versionist'
gem 'devise'
gem 'koala'

gem 'google_maps_service', '~> 0.4.1'
gem 'sparsematrix'
gem 'sparse_array'
gem 'walky-astar', path: "./gem/walky-astar"
gem 'sphericalc', path: "./gem/sphericalc"
gem 'ai4r', :git => "git://github.com/edwardsamuel/ai4r.git", :branch => "cut-tree-clustering"

group :development do
  gem 'rack-mini-profiler', require: false
end

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.4'
  gem 'factory_girl_rails', '~> 4.2.1'
  gem 'quiet_assets'
  gem 'awesome_print', :require => 'awesome_print'
  gem 'capistrano',           require: false
  gem 'capistrano-rvm',       require: false
  gem 'capistrano-rails',     require: false
  gem 'capistrano-bundler',   require: false
  gem 'capistrano3-puma',     require: false
  gem 'capistrano-passenger', require: false
end

group :test do
  gem 'rspec-its', '~> 1.2'
  gem 'rspec-collection_matchers', '~> 1.1.2'
  gem 'api_matchers'
  gem 'shoulda-matchers', '~> 3.0'
  gem 'faker', '~> 1.1.2'
  gem 'capybara', '~> 2.7.0'
  gem 'database_cleaner', '~> 1.0.1'
  gem 'launchy', '~> 2.3.0'
  gem 'selenium-webdriver', '~> 2.39.0'
end
