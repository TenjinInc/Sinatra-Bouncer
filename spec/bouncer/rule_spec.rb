# frozen_string_literal: true

require_relative '../spec_helper'

describe Sinatra::Bouncer::Rule do
   describe 'initialize' do
      it 'should raise an error if not provided a block' do
         expect do
            described_class.new
         end.to raise_error ArgumentError, 'must provide a block to Bouncer::Rule'
      end
   end

   describe '#can' do
      let(:rule) do
         Sinatra::Bouncer::Rule.new do
            true
         end
      end

      it 'should raise an error if provided a block' do
         msg = <<~ERR
            You cannot provide a block to #can. If you wish to conditionally allow, use #can_sometimes instead.
         ERR

         expect do
            rule.can post: '/some-path' do
               # stub
            end
         end.to raise_error Sinatra::Bouncer::BouncerError, msg.chomp
      end

      it 'should define a rule using can_sometimes' do
         rule.can post: '/some-path'

         expect(rule.allow?(:post, '/some-path', {})).to be true
      end
   end

   describe '#can_sometimes' do
      let(:context) { double('request context') }
      let(:rule) do
         Sinatra::Bouncer::Rule.new do
            true
         end
      end

      it 'should raise error when not provided a method or routes list' do
         err = 'must provide a hash where keys are HTTP method symbols and values are one or more path matchers'

         expect do
            rule.can_sometimes do
               # whatever
            end
         end.to raise_error ArgumentError, err
      end

      it 'should not raise an error if provided a block' do
         expect do
            rule.can_sometimes get: '/some-path' do
               # whatever
            end
         end.to_not raise_error
      end

      it 'should raise an error if not provided a block' do
         msg = <<~ERR
            You must provide a block to #can_sometimes. If you wish to always allow, use #can instead.
         ERR

         expect do
            rule.can_sometimes get: '/some-path'
         end.to raise_error(Sinatra::Bouncer::BouncerError, msg.chomp)
      end

      it 'should accept :all to mean all paths' do
         rule.can_sometimes get: :all do
            true
         end

         expect(rule.allow?(:get, '/some-path', context)).to be true
      end

      # HTTP HEAD method is, by definition equal to a GET request, so any legal GET path should also define a HEAD
      it 'should implicitly define HEAD access when GET is defined' do
         rule.can_sometimes get: '/some-path' do
            true
         end

         expect(rule.allow?(:head, '/some-path', context)).to be true
      end

      it 'should complain when a key is not an HTTP method' do
         methods = Sinatra::Bouncer::Rule::HTTP_METHOD_SYMBOLS

         expect do
            rule.can_sometimes bogus: '/some-path' do
               # whatever
            end
         end.to raise_error Sinatra::Bouncer::BouncerError,
                            "'bogus' is not a known HTTP method key. Must be one of: #{ methods }"
      end

      it 'should accept a single path' do
         rule.can_sometimes post: '/some-path' do
            true
         end

         expect(rule.allow?(:post, '/some-path', context)).to be true
      end

      it 'should accept a list of paths' do
         rule.can_sometimes post: %w[/some-path /other-path] do
            true
         end

         expect(rule.allow?(:post, '/some-path', context)).to be true
         expect(rule.allow?(:post, '/other-path', context)).to be true
      end

      it 'should accept a splat' do
         rule.can_sometimes post: '/directory/*' do
            true
         end

         expect(rule.allow?(:post, '/directory/some-path', context)).to be true
      end
   end

   describe '#incomplete?' do
      let(:rule) do
         Sinatra::Bouncer::Rule.new do
            true
         end
      end

      it 'should be true when no routes are defined' do
         expect(rule.incomplete?).to be true
      end

      it 'should be false when routes are defined' do
         rule.can get: '/something'

         expect(rule.incomplete?).to be false
      end
   end

   describe '#allow?' do
      let(:rule) do
         Sinatra::Bouncer::Rule.new do
            true
         end
      end

      let(:request) { double('rack request object') }
      let(:context) { double('request handler context', request: request) }

      it 'should match simple paths' do
         rule.can get: '/some-path'

         expect(rule.allow?(:get, '/some-path', context)).to be true
      end

      it 'should append leading slashes to the given path' do
         rule.can get: 'some-path'

         expect(rule.allow?(:get, '/some-path', context)).to be true
      end

      it 'should append leading slashes to the tested path' do
         rule.can get: '/other-path'

         expect(rule.allow?(:get, 'other-path', context)).to be true
      end

      it 'should match splats' do
         rule.can get: '/directory/*'

         %w[/directory/one /directory/two /directory/three].each do |path|
            expect(rule.allow?(:get, path, context)).to be true
         end
      end

      it 'should NOT match empty string to a splat' do
         rule.can get: '/directory/*'

         expect(rule.allow?(:get, '/directory/', context)).to be false
      end

      it 'should require that both paths are same length' do
         rule.can get: '/directory/*'

         %w[/directory /directory/extra/length].each do |path|
            expect(rule.allow?(:get, path, context)).to be false
         end
      end

      it 'should raise an error if a role block returns nonbool truthy value' do
         rule = Sinatra::Bouncer::Rule.new { 5 }

         rule.can get: '/something'

         expect { rule.allow?(:get, 'something', context) }.to raise_error Sinatra::Bouncer::BouncerError
      end

      it 'should raise an error if a condition returns nonbool truthy value' do
         rule.can_sometimes get: '/other' do
            5
         end

         expect { rule.allow?(:get, 'other', context) }.to raise_error Sinatra::Bouncer::BouncerError
      end

      it 'should return true when the role block is true' do
         rule = Sinatra::Bouncer::Rule.new { true }

         rule.can get: '/something'

         expect(rule.allow?(:get, 'something', context)).to be true
      end

      it 'should return true when the condition block is true' do
         rule.can_sometimes get: '/something' do
            true
         end

         expect(rule.allow?(:get, 'something', context)).to be true
      end

      it 'should execute the role block in the context of the request' do
         req  = request
         rule = Sinatra::Bouncer::Rule.new do
            request == req
         end

         rule.can get: '/something'

         expect(rule.allow?(:get, 'something', context)).to be true
      end

      it 'should execute the condition block in the context of the request' do
         req = request

         rule.can_sometimes get: '/something' do
            request == req
         end

         expect(rule.allow?(:get, 'something', context)).to be true
      end

      it 'should return false when the role block is false' do
         rule = Sinatra::Bouncer::Rule.new { false }

         rule.can get: '/something'

         expect(rule.allow?(:get, 'something', context)).to be false
      end

      it 'should return false when the role block is falsey' do
         rule = Sinatra::Bouncer::Rule.new { nil }

         rule.can get: '/something'

         expect(rule.allow?(:get, 'something', context)).to be false
      end

      it 'should return false when the block is false' do
         rule.can_sometimes get: '/something' do
            false
         end

         expect(rule.allow?(:get, 'something', context)).to be false
      end

      it 'should return false when the block is falsey' do
         rule.can_sometimes get: '/something' do
            nil
         end

         expect(rule.allow?(:get, 'something', context)).to be false
      end
   end
end
