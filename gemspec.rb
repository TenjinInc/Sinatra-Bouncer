Gem::Specification.new do |s|
  s.name         = 'bouncer'
  s.version      = '0.9'
  s.date         = Time.now.strftime('%Y-%m-%d')
  s.summary      = 'Sinatra permissions plugin'
  s.description  = 'Bouncer brings simple authorization to Sinatra, inspired by Ryan Bates\' CanCan API.'
  s.authors      = ['Tenjin', 'Robin Miller']
  s.email        = 'contact@tenjin.ca'
  s.homepage     = 'http://www.tenjin.ca'

  s.files        = `git ls-files`.split("\n").reject { |path| path =~ /\.gitignore$|.*\.gemspec$/ }

  s.required_ruby_version = '>= 1.9.3'

  # Dependencies
  # s.add_dependency 'activesupport', '>= 3.2'

  # Development-only dependencies
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rspec', '~> 2.14.1'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'factory_girl', '~> 4.0'
  s.add_development_dependency 'parallel_tests'
end