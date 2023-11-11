# frozen_string_literal: true

require_relative '../spec_helper'

describe Sinatra::Bouncer::BasicBouncer do
   let(:bouncer) { Sinatra::Bouncer::BasicBouncer.new }

   describe '#can' do
      it 'should raise an error if provided a block' do
         msg = <<~ERR
            You cannot provide a block to #can. If you wish to conditionally allow, use #can_sometimes instead.
         ERR

         expect do
            bouncer.can(:post, 'some_path') do
               # stub
            end
         end.to raise_error(Sinatra::Bouncer::BouncerError, msg.chomp)
      end

      it 'should handle a list of paths' do
         bouncer.can(:post, 'some_path', 'other_path')

         expect(bouncer.can?(:post, 'some_path')).to be true
         expect(bouncer.can?(:post, 'other_path')).to be true
      end

      it 'should accept a splat' do
         bouncer.can(:post, 'directory/*')

         expect(bouncer.can?(:post, 'directory/some_path')).to be true
      end
   end

   describe '#can_sometimes' do
      it 'should accept :any_method to mean all http methods' do
         bouncer.can_sometimes(:any_method, 'some_path') do
            true
         end

         expect(bouncer.can?(:get, 'some_path')).to be true
         expect(bouncer.can?(:post, 'some_path')).to be true
         expect(bouncer.can?(:put, 'some_path')).to be true
         expect(bouncer.can?(:delete, 'some_path')).to be true
         expect(bouncer.can?(:options, 'some_path')).to be true
         expect(bouncer.can?(:link, 'some_path')).to be true
         expect(bouncer.can?(:unlink, 'some_path')).to be true
         expect(bouncer.can?(:head, 'some_path')).to be true
         expect(bouncer.can?(:trace, 'some_path')).to be true
         expect(bouncer.can?(:connect, 'some_path')).to be true
         expect(bouncer.can?(:patch, 'some_path')).to be true
      end

      it 'should accept :all to mean all paths' do
         bouncer.can_sometimes(:get, :all) do
            true
         end

         expect(bouncer.can?(:get, 'some_path')).to be true
      end

      it 'should accept a list of paths' do
         bouncer.can_sometimes(:post, 'some_path', 'other_path') do
            true
         end

         expect(bouncer.can?(:post, 'some_path')).to be true
         expect(bouncer.can?(:post, 'other_path')).to be true
      end

      it 'should accept a splat' do
         bouncer.can_sometimes(:post, 'directory/*') do
            true
         end

         expect(bouncer.can?(:post, 'directory/some_path')).to be true
      end

      it 'should not raise an error if provided a block' do
         expect do
            bouncer.can_sometimes(:any_method, 'some_path') do
               true
            end
         end.to_not raise_error
      end

      it 'should raise an error if not provided a block' do
         msg = <<~ERR
            You must provide a block to #can_sometimes. If you wish to always allow, use #can instead.
         ERR

         expect do
            bouncer.can_sometimes(:any_method, 'some_path')
         end.to raise_error(Sinatra::Bouncer::BouncerError, msg.chomp)
      end
   end

   describe '#can?' do
      it 'should pass when declared allowed' do
         bouncer.can(:any_method, 'some_path')

         expect(bouncer.can?(:post, 'some_path')).to be true
      end

      it 'should fail when not declared allowed' do
         expect(bouncer.can?(:post, 'some_path')).to be false
      end

      it 'should pass if the rule block passes' do
         bouncer.can_sometimes(:any_method, 'some_path') do
            true
         end

         expect(bouncer.can?(:post, 'some_path')).to be true
      end

      it 'should fail if the rule block fails' do
         bouncer.can_sometimes(:any_method, 'some_path') do
            false
         end

         expect(bouncer.can?(:post, 'some_path')).to be false
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
