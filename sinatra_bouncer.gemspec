Gem::Specification.new do |s|
  s.name = 'sinatra-bouncer'
  s.version = '1.0.2'
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'Sinatra permissions plugin'
  s.description = 'Bouncer brings simple authorization to Sinatra.'
  s.authors = ['Tenjin', 'Robin Miller']
  s.email = 'contact@tenjin.ca'
  s.homepage = 'http://www.tenjin.ca'

  s.files = `git ls-files`.split("\n").reject do |path|
    path =~ %r{^\.gitignore$|^.*\.gemspec$|^tests/}
  end

  s.required_ruby_version = '>= 1.9.3'

  # Dependencies
  s.add_dependency 'sinatra' #, '>= 3.2' # TODO: determine a precise version
  # s.add_dependency 'activesupport', '>= 3.2'

  # Development-only dependencies
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rspec', '~> 2.14.1'
  s.add_development_dependency 'cucumber', '~> 1.3.19'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'launchy'
  # s.add_development_dependency 'factory_girl', '~> 4.0'
  s.add_development_dependency 'parallel_tests'
end