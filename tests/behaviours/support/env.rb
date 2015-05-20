src_dir = File.expand_path('../../..', File.dirname(__FILE__))
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

# require 'lib/sinatra/bouncer'

require 'capybara/cucumber'
require 'rspec/expectations'

require 'tests/test_app'
# require 'faces/web/sinatra/routes'
# require 'core/tests/behaviours/support/env'

# == CAPYBARA ==
Capybara.app = Sinatra::Application #TestApp.new

# Set this to whatever the server's normal port is for you. Sinatra is 4567; rack 9292 by default.
# Also note: you have to be running the server for this to work.
Capybara.asset_host = 'http://localhost:4567'

# == REGULAR SETTINGS ==
Before do
  Capybara.reset_sessions!
  # @current_user = nil
  visit('/')
end

World do
  RSpec::Matchers
end
