# frozen_string_literal: true

Gem::Specification.new do |s|
   s.name        = 'sinatra-bouncer'
   s.version     = '1.2.0'
   s.summary     = 'Sinatra permissions plugin'
   s.description = 'Bouncer brings simple authorization to Sinatra.'
   s.authors     = ['Tenjin', 'Robin Miller']
   s.email       = 'contact@tenjin.ca'
   s.homepage    = 'http://www.tenjin.ca'

   s.files = `git ls-files`.split("\n").reject do |path|
      path =~ %r{^\.gitignore$|^.*\.gemspec$|^tests/}
   end

   s.required_ruby_version = '>= 2.7'

   s.add_dependency 'sinatra', '>= 2.2'
end
