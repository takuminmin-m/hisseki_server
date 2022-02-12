source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

gem 'rails'

gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use Puma as the app server
gem 'puma'

gem "importmap-rails"

gem "turbo-rails"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

gem "stimulus-rails"

gem "cssbundling-rails"

gem "sassc-rails"

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# 画像アップロード用
gem 'carrierwave'
# carrierwave-data-uriの依存ライブラリ
# ruby3.1.0でバグが発生するため、PRが承諾されるまではtakuminmin-mのリポジトリを使用
# 該当PR: https://github.com/dball/data_uri/pull/10
gem "data_uri", github: "takuminmin-m/data_uri"
# canvasの画像をdataurlでアップロードできるように
gem "carrierwave-data-uri"
# 画像のバリデーション用に imagemagick必須
gem "mini_magick"

# 筆跡判定用
# gem "numpy"
gem "pycall", github: "mrkn/pycall.rb"
# gem "pandas"

# 認証用
gem "sorcery"

# バグ防止
gem "concurrent-ruby"

# markdown対応
gem "redcarpet"
gem "coderay"

gem "csv"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler'
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem "rubocop-rspec",  require: false
  gem "spring-commands-rspec"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
