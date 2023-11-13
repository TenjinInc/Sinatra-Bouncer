# frozen_string_literal: true

require_relative '../spec_helper'

describe Sinatra::Bouncer::BasicBouncer do
   let(:bouncer) { Sinatra::Bouncer::BasicBouncer.new }

   let(:context) { double('request context') }

   describe '#can' do
      it 'should raise an error if provided a block' do
         msg = <<~ERR
            You cannot provide a block to #can. If you wish to conditionally allow, use #can_sometimes instead.
         ERR

         expect do
            bouncer.can post: '/some-path' do
               # stub
            end
         end.to raise_error(Sinatra::Bouncer::BouncerError, msg.chomp)
      end

      it 'should define a rule using can_sometimes' do
         bouncer.can post: '/some-path'

         expect(bouncer.can?(:post, '/some-path', context)).to be true
      end
   end

   describe '#can_sometimes' do
      it 'should accept :any to mean all http methods' do
         bouncer.can_sometimes any: '/some-path' do
            true
         end

         methods = Sinatra::Bouncer::BasicBouncer::HTTP_METHODS.collect do |http_method|
            http_method.downcase.to_sym
         end

         methods.each do |http_method|
            err = "expected HTTP '#{ http_method }' to be accepted, was rejected"
            expect(bouncer.can?(http_method, '/some-path', context)).to be(true), err
         end
      end

      it 'should accept :all to mean all paths' do
         bouncer.can_sometimes get: :all do
            true
         end

         expect(bouncer.can?(:get, '/some-path', context)).to be true
      end

      # HTTP HEAD method is, by definition equal to a GET request, so any legal GET path should also define a HEAD
      it 'should implicitly define HEAD access when GET is defined' do
         bouncer.can_sometimes get: '/some-path' do
            true
         end

         expect(bouncer.can?(:head, '/some-path', context)).to be true
      end

      it 'should complain when a key is not an HTTP method' do
         methods = Sinatra::Bouncer::BasicBouncer::HTTP_METHOD_SYMBOLS

         expect do
            bouncer.can_sometimes bogus: '/some-path' do
               true
            end
         end.to raise_error Sinatra::Bouncer::BouncerError,
                            "'bogus' is not a known HTTP method key. Must be one of: #{ methods } or :any"
      end

      it 'should accept a single path' do
         bouncer.can_sometimes post: '/some-path' do
            true
         end

         expect(bouncer.can?(:post, '/some-path', context)).to be true
      end

      it 'should accept a list of paths' do
         bouncer.can_sometimes post: %w[/some-path /other-path] do
            true
         end

         expect(bouncer.can?(:post, '/some-path', context)).to be true
         expect(bouncer.can?(:post, '/other-path', context)).to be true
      end

      it 'should accept a splat' do
         bouncer.can_sometimes post: '/directory/*' do
            true
         end

         expect(bouncer.can?(:post, '/directory/some-path', context)).to be true
      end

      it 'should not raise an error if provided a block' do
         expect do
            bouncer.can_sometimes any: '/some-path' do
               true
            end
         end.to_not raise_error
      end

      it 'should raise an error if not provided a block' do
         msg = <<~ERR
            You must provide a block to #can_sometimes. If you wish to always allow, use #can instead.
         ERR

         expect do
            bouncer.can_sometimes any: '/some-path'
         end.to raise_error(Sinatra::Bouncer::BouncerError, msg.chomp)
      end
   end

   describe '#can?' do
      it 'should pass when declared allowed' do
         bouncer.can any: '/some-path'

         expect(bouncer.can?(:post, '/some-path', context)).to be true
      end

      it 'should fail when not declared allowed' do
         expect(bouncer.can?(:post, '/some-path', context)).to be false
      end

      it 'should pass if the rule block passes' do
         bouncer.can_sometimes(any: '/some-path') do
            true
         end

         expect(bouncer.can?(:post, 'some-path', context)).to be true
      end

      it 'should fail if the rule block fails' do
         bouncer.can_sometimes any: 'some-path' do
            false
         end

         expect(bouncer.can?(:post, 'some-path', context)).to be false
      end
   end

   describe '#bounce' do
      it 'should run the bounce_with block on sinatra instance' do
         runner  = nil
         sinatra = double('sinatra')

         bouncer.bounce_with = proc do
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
