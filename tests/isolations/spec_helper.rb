src_dir = File.expand_path('../..', File.dirname(__FILE__))
$LOAD_PATH.unshift(src_dir) unless $LOAD_PATH.include?(src_dir)

require 'rspec'
require 'lib/sinatra/bouncer'
