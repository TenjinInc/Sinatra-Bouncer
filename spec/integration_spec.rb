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

            Sinatra::Bouncer::BasicBouncer::HTTP_METHOD_SYMBOLS.each do |http_method|
               send(http_method, route_path) do
                  test_body
               end
            end
         end
      end

      let(:browser) { Rack::Test::Session.new(server_klass) }

      it 'should auto-protect all HTTP methods' do
         Sinatra::Bouncer::BasicBouncer::HTTP_METHOD_SYMBOLS.each do |http_method|
            response = browser.send http_method, path

            expect(response).to be_forbidden
            expect(response.body).to_not include test_body
         end
      end
   end

   describe 'rules' do
      it 'should allow access to matching route string' do
         path      = '/admin/dashboard'
         test_body = 'Test content'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            rules do
               can get: path
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
         test_body = 'Test content'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            rules do
               can get: paths
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
         test_body = 'Test content'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               test_body
            end

            post path do
               test_body
            end

            rules do
               can get:  path,
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

      it 'should evaludate the rules block once at startup' do
         path = '/admin/dashboard'

         runs = 0

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               'Test content'
            end

            rules do
               runs += 1

               can get: path
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         response = browser.get path
         expect(response).to be_ok # sanity check

         response = browser.get path
         expect(response).to be_ok # sanity check

         expect(runs).to eq 1
      end

      it 'should evaluate rule conditions in the context of the request' do
         path = '/admin/dashboard'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               'Test content'
            end

            rules do
               can_sometimes get: path do
                  request.get_header('X-CUSTOM') == 'special'
               end
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         # first attempt should succeed and flip the has_run variable
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
               can_sometimes get: path do
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
               'Test content'
            end

            rules do
               can get: path
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         response = browser.head path

         expect(response).to be_ok
      end

      it 'should NOT allow access to GET when HEAD is specified' do
         path      = '/admin/dashboard'
         test_body = 'Test content'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               test_body
            end

            rules do
               can head: path
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
               'stuff'
            end

            rules do
               can_sometimes get: path do
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
         path = '/admin/dashboard'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            get path do
               'stuff'
            end

            rules do
               can_sometimes get: path do
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
            test_body = 'Test content'

            server_klass = Class.new Sinatra::Base do
               register Sinatra::Bouncer

               get '/admin/dashboard' do
                  test_body
               end

               rules do
                  can get: '/admin/*'
               end
            end

            browser = Rack::Test::Session.new(server_klass)

            response = browser.get '/admin/dashboard'

            expect(response).to be_ok
            expect(response.body).to eq test_body
         end

         it 'should match wildcards in the middle' do
            test_body = 'Test content'

            server_klass = Class.new Sinatra::Base do
               register Sinatra::Bouncer

               get '/admin/dashboard' do
                  test_body
               end

               rules do
                  can get: '/*/dashboard'
               end
            end

            browser = Rack::Test::Session.new(server_klass)

            response = browser.get '/admin/dashboard'

            expect(response).to be_ok
            expect(response.body).to eq test_body
         end
      end
   end

   describe 'custom bounce behaviour' do
      it 'should use the custom bounce behaviour' do
         path      = '/admin/dashboard'
         test_body = 'Test content'

         server_klass = Class.new Sinatra::Base do
            register Sinatra::Bouncer

            rules do
               # none
            end

            bounce_with do
               halt 418 # teapots are not allowed
            end

            get path do
               test_body
            end
         end

         browser = Rack::Test::Session.new(server_klass)

         response = browser.get path

         expect(response.status).to be 418
      end
   end
end
