source 'http://rubygems.org'

gem 'rails', '3.0.6'

gem 'sqlite3'

group :development, :test do
  gem 'rspec-rails', '~> 2.5.0'

  # debugger for ruby 1.9
  gem 'ruby-debug19', :require => 'ruby-debug'

  # debugger for ruby 1.8
  # gem 'ruby-debug'
  
  # run specs continuously
  gem 'guard-rspec'

  # speed up tests with spork
  gem 'guard-spork'

  # use the RC to get around issues with 0.8.x
  gem 'spork', '0.9.0.rc8'

  # use FSEvent support in guard for OS X
  gem 'rb-fsevent'

  # for guard notifications in OS X
  gem 'growl'

  # rspec formatter with progress bar and instafail
  gem 'fuubar'
end

# ruote
gem "ruote", ">=2.2.0"
gem "ruote-kit", ">=2.2.0"
gem 'erwin-ruote-mongodb', :git=>"git://github.com/erwin/ruote-mongodb.git"

# mongoid and friends
gem "mongoid", "~>2.0.0"
gem "bson_ext"
gem 'acts_as_list_mongoid', :git=>"git://github.com/kristianmandrup/acts_as_list_mongoid.git"
gem 'mongoid_embedded_helper', :git => "git://github.com/kristianmandrup/mongoid_embedded_helper.git"
gem 'mongoid_adjust', :git => "git://github.com/kristianmandrup/mongoid_adjust.git"

# this gets around gems that are using json_pure and having problems
gem 'json', '1.5.3'
