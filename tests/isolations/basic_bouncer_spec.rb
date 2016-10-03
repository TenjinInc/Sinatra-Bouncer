require_relative 'spec_helper'

describe Sinatra::Bouncer::BasicBouncer do
   let(:bouncer) { Sinatra::Bouncer::BasicBouncer.new }

   describe '#can' do
      it 'should raise an error if provided a block' do
         expect do
            bouncer.can(:post, 'some_path') do

            end
         end.to raise_error(Sinatra::Bouncer::BouncerError, 'You cannot provide a block to #can. If you wish to conditionally allow, use #can_sometimes instead.')
      end

      it 'should handle a list of paths' do
         bouncer.can(:post, 'some_path', 'other_path')

         bouncer.can?(:post, 'some_path').should be_true
         bouncer.can?(:post, 'other_path').should be_true
      end

      it 'should accept a splat' do
         bouncer.can(:post, 'directory/*')

         bouncer.can?(:post, 'directory/some_path').should be_true
      end
   end

   describe '#can_sometimes' do
      let(:block_error_msg) { 'You must provide a block to #can_sometimes. If you wish to always allow, use #can instead.' }

      it 'should accept :any_method to mean all http methods' do
         bouncer.can_sometimes(:any_method, 'some_path') do
            true
         end

         bouncer.can?(:get, 'some_path').should be_true
         bouncer.can?(:post, 'some_path').should be_true
         bouncer.can?(:put, 'some_path').should be_true
         bouncer.can?(:delete, 'some_path').should be_true
         bouncer.can?(:options, 'some_path').should be_true
         bouncer.can?(:link, 'some_path').should be_true
         bouncer.can?(:unlink, 'some_path').should be_true
         bouncer.can?(:head, 'some_path').should be_true
         bouncer.can?(:trace, 'some_path').should be_true
         bouncer.can?(:connect, 'some_path').should be_true
         bouncer.can?(:patch, 'some_path').should be_true
      end

      it 'should accept :all to mean all paths' do
         bouncer.can_sometimes(:get, :all) do
            true
         end

         bouncer.can?(:get, 'some_path').should be_true
      end

      it 'should accept a list of paths' do
         bouncer.can_sometimes(:post, 'some_path', 'other_path') do
            true
         end

         bouncer.can?(:post, 'some_path').should be_true
         bouncer.can?(:post, 'other_path').should be_true
      end

      it 'should accept a splat' do
         bouncer.can_sometimes(:post, 'directory/*') do
            true
         end

         bouncer.can?(:post, 'directory/some_path').should be_true
      end

      it 'should not raise an error if provided a block' do
         expect do
            bouncer.can_sometimes(:any_method, 'some_path') do
               true
            end
         end.to_not raise_error
      end

      it 'should raise an error if not provided a block' do
         expect do
            bouncer.can_sometimes(:any_method, 'some_path')
         end.to raise_error(Sinatra::Bouncer::BouncerError, block_error_msg)
      end
   end

   describe '#can?' do
      it 'should pass when declared allowed' do
         bouncer.can(:any_method, 'some_path')

         bouncer.can?(:post, 'some_path').should be_true
      end

      it 'should fail when not declared allowed' do
         bouncer.can?(:post, 'some_path').should be_false
      end

      it 'should pass if the rule block passes' do
         bouncer.can_sometimes(:any_method, 'some_path') do
            true
         end

         bouncer.can?(:post, 'some_path').should be_true
      end

      it 'should fail if the rule block fails' do
         bouncer.can_sometimes(:any_method, 'some_path') do
            false
         end

         bouncer.can?(:post, 'some_path').should be_false
      end
   end

   describe '#bounce' do
      it 'should run the bounce_with block on sinatra instance' do
         runner  = nil
         sinatra = double('sinatra')

         bouncer.bounce_with = Proc.new do
            runner = self # self should be the sinatra double
         end

         bouncer.bounce(sinatra)

         runner.should == sinatra
      end

      it 'should halt 403 if no block provided' do
         app = double('sinatra')

         app.should_receive(:halt).with(403)

         bouncer.bounce(app)
      end
   end
end
