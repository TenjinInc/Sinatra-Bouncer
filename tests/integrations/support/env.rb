# frozen_string_literal: true

src_dir = File.expand_path('../../..', __dir__)
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

require 'simplecov'

SimpleCov.command_name 'spec'

require 'capybara/cucumber'
require 'rspec/expectations'

require 'tests/test_app'

# == CAPYBARA ==
Capybara.app = Sinatra::Application

# Set this to whatever the server's normal port is for you. Sinatra is 4567; rack 9292 by default.
# Also note: you have to be running the server for this to work.
Capybara.asset_host = 'http://localhost:4567'

# == REGULAR SETTINGS ==
Before do
   Capybara.reset_sessions!
   Capybara.app.settings.bouncer.instance_variable_get(:@ruleset).clear

   @allowed_once_paths = []
end

World do
   RSpec::Matchers
end
