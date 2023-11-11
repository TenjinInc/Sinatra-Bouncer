# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Integration Tests' do
   let :http_methods do
      # not covering LINK or UNLINK due to rarity
      %w[GET HEAD PUT POST DELETE OPTIONS PATCH]
   end

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
         http_methods.each do |http_method|
            server_klass.send(http_method.downcase, path) do
               test_body
            end
         end
      end

      it 'should auto-protect all HTTP methods' do
         http_methods.each do |http_method|
            response = browser.send http_method.downcase, path

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
            # TODO: can get: path
            can :get, path
         end

         response = browser.get path

         expect(response).to be_ok
         expect(response.body).to eq test_body
      end

      it 'should allow access to matching route string array' do
         paths     = %w[/admin/dashboard /admin/settings]
         test_body = 'Test content'

         server_klass.rules do
            # TODO: can get: paths
            can :get, *paths
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

      # AKA it should wipe permissions between requests
      it 'should evaluate each request separately' do
         path = '/admin/dashboard'

         has_run = false

         server_klass.get path do
            has_run = true
         end

         server_klass.rules do
            # TODO: can_sometimes get: path
            can_sometimes :get, path do
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

      describe 'wildcards' do
         it 'should match wildcards at the end' do
            test_body = 'Test content'

            server_klass.get '/admin/dashboard' do
               test_body
            end

            server_klass.rules do
               # TODO: can get: '/admin/*'
               can :get, '/admin/*'
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
               # TODO: can get: '/*/dashboard'
               can :get, '/*/dashboard'
            end

            response = browser.get '/admin/dashboard'

            expect(response).to be_ok
            expect(response.body).to eq test_body
         end
      end
   end
end
