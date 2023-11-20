# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Integration Tests' do
   describe 'auto-protection' do
      let(:path) { '/test' }
      let(:test_body) { 'Page content' }

      let(:server_klass) do
         route_path = path

         Class.new Sinatra::Base do
            register Sinatra::Bouncer

            rules do
               # no rules
            end

            Sinatra::Bouncer::Rule::HTTP_METHOD_SYMBOLS.each do |http_method|
               send(http_method, route_path) do
                  # whatever
               end
            end
         end
      end

      let(:browser) { Rack::Test::Session.new(server_klass) }

      it 'should auto-protect all HTTP methods' do
         Sinatra::Bouncer::Rule::HTTP_METHOD_SYMBOLS.each do |http_method|
            response = browser.send http_method, path

            expect(response).to be_forbidden
         end
      end
   end

   describe 'rules' do
      it 'should allow access to matching route string' do
         path      = '/admin/dashboard'
         test_body = 'Boring is always best.'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            rules do
               anyone.can get: path
            end

            get path do
               test_body
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         response = browser.get path

         expect(response).to be_ok
         expect(response.body).to eq test_body
      end

      it 'should allow access to matching route string array' do
         paths     = %w[/admin/dashboard /admin/settings]
         test_body = 'Boring is always best.'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            rules do
               anyone.can get: paths
            end

            paths.each do |path|
               get path do
                  test_body
               end
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         paths.each do |path|
            response = browser.get path

            expect(response).to be_ok
            expect(response.body).to eq test_body
         end
      end

      it 'should allow access to matching hash of methods to routes' do
         path      = '/admin/dashboard'
         test_body = 'Boring is always best.'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               test_body
            end

            post path do
               test_body
            end

            rules do
               anyone.can get:  path,
                          post: path
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         response = browser.get path

         expect(response).to be_ok
         expect(response.body).to eq test_body

         response = browser.post path

         expect(response).to be_ok
         expect(response.body).to eq test_body
      end

      it 'should evaluate the rules block once at startup' do
         path = '/admin/dashboard'

         runs = 0

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               'Boring is always best.'
            end

            rules do
               runs += 1

               anyone.can get: path
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         response = browser.get path
         expect(response).to be_ok # sanity check

         response = browser.get path
         expect(response).to be_ok # sanity check

         expect(runs).to eq 1
      end

      it 'should accept defining roles' do
         path = '/admin/dashboard'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               'Boring is always best.'
            end

            role :user do
               # dummy user session handling for testing - do not do it this way in real life
               current_user = JSON.parse(request.get_header('X-FAKE-SESSION'))

               !current_user.nil?
            end

            rules do
               user.can get: path
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         rack_env = {'X-FAKE-SESSION' => {name: 'Michael Bryce'}.to_json}
         response = browser.get(path, {}, rack_env)
         expect(response).to be_ok
      end

      it 'should evaluate both role and rule conditions' do
         path = '/admin/dashboard'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               # whatever
            end

            role :user do
               request.get_header('X-CUSTOM-USER') == 'Bryce'
            end

            rules do
               user.can_sometimes get: path do
                  request.get_header('X-CUSTOM-COND') == 'special'
               end
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         rack_env = {'X-CUSTOM-COND' => 'special'}
         response = browser.get(path, {}, rack_env)
         expect(response).to be_forbidden

         rack_env = {'X-CUSTOM-USER' => 'Bryce'}
         response = browser.get(path, {}, rack_env)
         expect(response).to be_forbidden
      end

      it 'should evaluate role definitions in the context of the request' do
         path = '/admin/dashboard'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               'Boring is always best.'
            end

            role :user do
               !current_user.nil?
            end

            rules do
               user.can get: path
            end

            helpers do
               # dummy user session handling for testing - do not do it this way in real life
               def current_user
                  user = request.get_header('X-FAKE-SESSION')

                  user ? JSON.parse(user) : nil
               end
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         rack_env = {}
         response = browser.get(path, {}, rack_env)
         expect(response).to be_forbidden

         rack_env = {'X-FAKE-SESSION' => {name: 'Michael Bryce'}.to_json}
         response = browser.get(path, {}, rack_env)
         expect(response).to be_ok
      end

      it 'should evaluate rule conditions in the context of the request' do
         path = '/admin/dashboard'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               'Boring is always best.'
            end

            rules do
               anyone.can_sometimes get: path do
                  request.get_header('X-CUSTOM') == 'special'
               end
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         rack_env = {'X-CUSTOM' => 'special'}
         response = browser.get(path, {}, rack_env)
         expect(response).to be_ok
      end

      # AKA it should wipe permissions between requests
      it 'should evaluate each request separately' do
         path = '/admin/dashboard'

         has_run = false

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               has_run = true
            end

            rules do
               anyone.can_sometimes get: path do
                  !has_run
               end
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         # first attempt should succeed and flip the has_run variable
         response = browser.get path
         expect(response).to be_ok

         # second attempt should fail
         response = browser.get path
         expect(response).to be_forbidden
      end

      it 'should allow access to HEAD when GET is specified' do
         path = '/admin/dashboard'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               'Boring is always best.'
            end

            rules do
               anyone.can get: path
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         response = browser.head path

         expect(response).to be_ok
      end

      it 'should NOT allow access to GET when HEAD is specified' do
         path = '/admin/dashboard'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               # whatever
            end

            rules do
               anyone.can head: path
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         response = browser.get path

         expect(response).to be_forbidden
      end

      it 'should complain if a rule returns a truthy non-true' do
         path = '/admin/dashboard'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               # whatever
            end

            rules do
               anyone.can_sometimes get: path do
                  5
               end
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         # first attempt should succeed and flip the has_run variable
         response = browser.get path
         expect(response).to be_server_error
      end

      it 'should NOT complain if a rule returns a falsey non-false' do
         path = '/blogs/hello-world'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               # whatever
            end

            rules do
               anyone.can_sometimes get: path do
                  nil
               end
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         # first attempt should succeed and flip the has_run variable
         response = browser.get path
         expect(response).to be_forbidden
      end

      describe 'wildcards' do
         it 'should match wildcards at the end' do
            test_body = 'Boring is always best.'

            server_klass = Class.new Sinatra::Base do
               register Sinatra::Bouncer

               get '/blogs/hello-world' do
                  test_body
               end

               rules do
                  anyone.can get: '/blogs/*'
               end
            end

            browser = Rack::Test::Session.new(server_klass)

            response = browser.get '/blogs/hello-world'

            expect(response).to be_ok
            expect(response.body).to eq test_body
         end

         it 'should match wildcards in the middle' do
            test_body = 'Boring is always best.'

            server_klass = Class.new Sinatra::Base do
               register Sinatra::Bouncer

               get '/blogs/hello-world' do
                  test_body
               end

               rules do
                  anyone.can get: '/*/hello-world'
               end
            end

            browser = Rack::Test::Session.new(server_klass)

            response = browser.get '/blogs/hello-world'

            expect(response).to be_ok
            expect(response.body).to eq test_body
         end
      end
   end

   describe 'custom bounce behaviour' do
      it 'should use the custom bounce behaviour' do
         path = '/admin/dashboard'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            rules do
               # none
            end

            bounce_with do
               halt 418 # teapots are not allowed
            end

            get path do
               # whatever
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         response = browser.get path

         expect(response.status).to be 418
      end
   end
end
