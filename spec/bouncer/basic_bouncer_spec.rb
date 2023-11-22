# frozen_string_literal: true

require_relative '../spec_helper'

describe Sinatra::Bouncer::BasicBouncer do
   let(:bouncer) { Sinatra::Bouncer::BasicBouncer.new }

   let(:context) { double('request context') }

   describe '#initialize' do
      it 'should register a default :anyone role' do
         anyone = bouncer.anyone

         # the rule should exist...
         expect(anyone).to be_a Sinatra::Bouncer::Rule

         # ... and it should be default true
         anyone.can get: '/something'
         expect(anyone.allow?(:get, 'something', {})).to be true
      end
   end

   describe '#rules' do
      it 'should execute the rules block' do
         expect(bouncer).to receive :something

         bouncer.rules do
            something
         end
      end

      it 'should NOT complain if all rules are fully defined' do
         expect do
            bouncer.rules do
               anyone.can get: '/something'
            end
         end.to_not raise_error
      end

      it 'should complain if any rule is not fully defined' do
         expect do
            bouncer.rules do
               anyone
            end
         end.to raise_error Sinatra::Bouncer::BouncerError, 'rules block error: missing #can or #can_sometimes call'
      end
   end

   describe '#role' do
      it 'should register a role under the given identifier' do
         bouncer.role :admin do
            true
         end

         expect(bouncer.admin).to be_a Sinatra::Bouncer::Rule
      end

      it 'should raise an error when no identifier is provided' do
         expect do
            bouncer.role nil do
               true
            end
         end.to raise_error ArgumentError, 'must provide a role identifier to #role'
      end

      it 'should raise an error when no block is provided' do
         expect do
            bouncer.role :admin
         end.to raise_error ArgumentError, 'must provide a role condition block to #role'
      end

      it 'should raise an error when the role was already defined' do
         expect do
            bouncer.role :admin do
               true
            end
            bouncer.role :admin do
               true
            end
         end.to raise_error ArgumentError, "role called 'admin' already defined"
      end

      it 'should respond to the role name' do
         bouncer.role :admin do
            true
         end

         expect(bouncer.respond_to?(:admin)).to be true
      end

      it 'should not respond to unknown methods' do
         expect(bouncer.respond_to?(:admin)).to be false
         expect { bouncer.admin }.to raise_error NoMethodError
      end

      it 'should suggest known methods' do
         bouncer.role :admin do
            true
         end

         # need to use a generic satisfy block because the normal raise_error matcher only tests the original message,
         # and does not include the DidYouMean message addition
         error_checker = satisfy do |error|
            error.is_a?(NoMethodError) && error.message.include?('Did you mean?  admin')
         end

         expect { bouncer.admind }.to raise_error error_checker
      end
   end

   describe '#can?' do
      it 'should pass when declared allowed' do
         bouncer.anyone.can post: '/some-path'

         expect(bouncer.can?(:post, '/some-path', context)).to be true
      end

      it 'should fail when not declared allowed' do
         expect(bouncer.can?(:post, '/some-path', context)).to be false
      end

      it 'should pass if the rule block passes' do
         bouncer.anyone.can_sometimes post: '/some-path' do
            true
         end

         expect(bouncer.can?(:post, 'some-path', context)).to be true
      end

      it 'should fail if the rule block fails' do
         bouncer.anyone.can_sometimes post: 'some-path' do
            false
         end

         expect(bouncer.can?(:post, 'some-path', context)).to be false
      end
   end

   describe '#bounce' do
      it 'should run the bounce_with block on sinatra instance' do
         runner  = nil
         sinatra = double('sinatra')

         bouncer.bounce_with do
            runner = self # self should be the sinatra double
         end

         bouncer.bounce(sinatra)

         expect(runner).to be sinatra
      end

      it 'should halt 403 if no block provided' do
         app = double('sinatra')

         expect(app).to receive(:halt).with(403)

         bouncer.bounce(app)
      end
   end
end
