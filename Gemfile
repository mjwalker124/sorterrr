source "https://rubygems.org"
ruby '2.3.1'
gem 'rails', '5.0.1'
gem 'responders', '> 2.1'
gem 'activerecord-session_store', '~> 1.0.0'
gem 'thin'

gem 'sqlite3', group: [:development, :test]
gem 'pg'

gem 'airbrake', git: 'https://github.com/epigenesys/airbrake.git', branch: 'airbrake-v4'

gem 'haml-rails'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'

gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'select2-rails'
gem 'epi_js'
gem 'jquery-ui-rails'

gem 'simple_form'
gem 'draper', git: 'https://github.com/hgani/draper.git'
gem 'ransack', '~> 1.8.0'

gem 'rubyzip'

gem 'polyamorous', '~> 1.3.1'

gem 'will_paginate', '~> 3.1.5'
gem 'bootstrap-will_paginate'

gem 'devise', '>= 4.0.0'
gem 'devise_ldap_authenticatable', '>= 0.8.5'
gem 'devise_cas_authenticatable', '>= 1.5.0'
gem 'cancancan'

gem 'whenever'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'delayed-plugins-airbrake'
gem 'daemons'

gem 'faker'
gem 'activerecord-import'
gem 'jquery-datatables-rails'
gem 'normalize-rails'
gem 'data-confirm-modal'
group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-wait', '~> 0.0.8'
  gem 'byebug'
end

group :development do
  gem 'listen'
  gem 'web-console'
  gem 'spring'

  gem 'capistrano', '~> 3.4'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails-collection'
  gem 'epi_deploy', git: 'https://github.com/epigenesys/epi_deploy.git'

  gem 'eventmachine'
  gem 'letter_opener'
  gem 'annotate'
  gem 'rubocop'
  gem 'rename'
  gem 'rails-erd'
  gem 'ruby-prof'
end

group :test do
  gem 'capybara-select2', git: 'https://github.com/goodwill/capybara-select2.git'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'poltergeist'
  gem 'rspec-instafail', require: false
  gem 'rspec-retry'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'simplecov'
end
