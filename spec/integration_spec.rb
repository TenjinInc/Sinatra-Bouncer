# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Integration Tests' do
   let(:server_klass) do
      Class.new Sinatra::Base do
         register Sinatra::Bouncer
      end
   end

   let(:settings) { server_klass.settings }

   let(:browser) do
      Rack::Test::Session.new(server_klass)
   end

   describe 'auto-protection' do
      let(:path) { '/test' }
      let(:test_body) { 'Page content' }

      before :each do
         Sinatra::Bouncer::BasicBouncer::HTTP_METHOD_SYMBOLS.each do |http_method|
            server_klass.send(http_method.downcase, path) do
               test_body
            end
         end
      end

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

         server_klass.get path do
            test_body
         end

         server_klass.rules do
            can get: path
         end

         response = browser.get path

         expect(response).to be_ok
         expect(response.body).to eq test_body
      end

      it 'should allow access to matching route string array' do
         paths     = %w[/admin/dashboard /admin/settings]
         test_body = 'Test content'

         server_klass.rules do
            can get: paths
         end

         paths.each do |path|
            server_klass.get path do
               test_body
            end

            response = browser.get path

            expect(response).to be_ok
            expect(response.body).to eq test_body
         end
      end

      it 'should allow access to matching hash of methods to routes' do
         path      = '/admin/dashboard'
         test_body = 'Test content'

         server_klass.get path do
            test_body
         end

         server_klass.post path do
            test_body
         end

         server_klass.rules do
            can get:  path,
                post: path
         end

         response = browser.get path

         expect(response).to be_ok
         expect(response.body).to eq test_body

         response = browser.post path

         expect(response).to be_ok
         expect(response.body).to eq test_body
      end

      # AKA it should wipe permissions between requests
      it 'should evaluate each request separately' do
         path = '/admin/dashboard'

         has_run = false

         server_klass.get path do
            has_run = true
         end

         server_klass.rules do
            can_sometimes get: path do
               !has_run
            end
         end

         # first attempt should succeed and flip the has_run variable
         response = browser.get path
         expect(response).to be_ok

         # second attempt should fail
         response = browser.get path
         expect(response).to be_forbidden
      end

      it 'should allow access to HEAD when GET is specified' do
         path = '/admin/dashboard'

         server_klass.get path do
            'Test content'
         end

         server_klass.rules do
            can get: path
         end

         response = browser.head path

         expect(response).to be_ok
      end

      it 'should NOT allow access to GET when HEAD is specified' do
         path      = '/admin/dashboard'
         test_body = 'Test content'

         server_klass.get path do
            test_body
         end

         server_klass.rules do
            can head: path
         end

         response = browser.get path

         expect(response).to be_forbidden
      end

      it 'should complain if a rule returns a truthy non-true' do
         path = '/admin/dashboard'

         server_klass.get path do
            'stuff'
         end

         server_klass.rules do
            can_sometimes get: path do
               5
            end
         end

         # first attempt should succeed and flip the has_run variable
         response = browser.get path
         expect(response).to be_server_error
      end

      it 'should NOT complain if a rule returns a falsey non-false' do
         path = '/admin/dashboard'

         server_klass.get path do
            'stuff'
         end

         server_klass.rules do
            can_sometimes get: path do
               nil
            end
         end

         # first attempt should succeed and flip the has_run variable
         response = browser.get path
         expect(response).to be_forbidden
      end

      describe 'wildcards' do
         it 'should match wildcards at the end' do
            test_body = 'Test content'

            server_klass.get '/admin/dashboard' do
               test_body
            end

            server_klass.rules do
               can get: '/admin/*'
            end

            response = browser.get '/admin/dashboard'

            expect(response).to be_ok
            expect(response.body).to eq test_body
         end

         it 'should match wildcards in the middle' do
            test_body = 'Test content'

            server_klass.get '/admin/dashboard' do
               test_body
            end

            server_klass.rules do
               can get: '/*/dashboard'
            end

            response = browser.get '/admin/dashboard'

            expect(response).to be_ok
            expect(response.body).to eq test_body
         end
      end
   end
end
