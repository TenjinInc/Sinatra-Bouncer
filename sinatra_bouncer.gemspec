# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'sinatra/bouncer/version'

Gem::Specification.new do |spec|
   spec.name    = 'sinatra-bouncer'
   spec.version = Sinatra::Bouncer::VERSION
   spec.authors = ['Tenjin Inc', 'Robin Miller']
   spec.email   = %w[contact@tenjin.ca robin@tenjin.ca]

   spec.summary     = 'Sinatra permissions plugin'
   spec.description = 'Bouncer brings simple authorization to Sinatra.'
   spec.homepage    = 'https://github.com/TenjinInc/Sinatra-Bouncer'
   spec.license     = 'MIT'
   spec.metadata    = {
         'rubygems_mfa_required' => 'true'
   }

   spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|integrations)/}) }
   spec.require_paths = ['lib']

   spec.required_ruby_version = '>= 2.7'

   spec.add_dependency 'sinatra', '>= 2.2'
end
