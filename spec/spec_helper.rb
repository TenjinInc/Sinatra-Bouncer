# frozen_string_literal: true

src_dir = File.expand_path('..', __dir__)
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

require 'simplecov'

SimpleCov.command_name 'spec'

require 'lib/sinatra/bouncer'

require 'rspec/matchers'
require 'rack/test'
require 'sinatra/base'
