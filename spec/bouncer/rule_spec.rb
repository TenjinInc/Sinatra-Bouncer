# frozen_string_literal: true

require_relative '../spec_helper'

describe Sinatra::Bouncer::Rule do
   describe '#match_path?' do
      it 'should match simple paths' do
         rule = Sinatra::Bouncer::Rule.new('/some_path') { true }

         expect(rule.match_path?('/some_path')).to be true
      end

      it 'should append leading slashes to the given path' do
         rule = Sinatra::Bouncer::Rule.new('some_path') { true }

         expect(rule.match_path?('/some_path')).to be true
      end

      it 'should append leading slashes to the tested path' do
         rule = Sinatra::Bouncer::Rule.new('/other_path') { true }

         expect(rule.match_path?('other_path')).to be true
      end

      it 'should match splats' do
         rule = Sinatra::Bouncer::Rule.new('/directory/*') { true }

         %w[/directory/one /directory/two /directory/three].each do |path|
            expect(rule.match_path?(path)).to be true
         end
      end

      it 'should NOT match empty string to a splat' do
         rule = Sinatra::Bouncer::Rule.new('/directory/*') { true }

         expect(rule.match_path?('/directory/')).to be false
      end

      it 'should require that both paths are same length' do
         rule = Sinatra::Bouncer::Rule.new('/directory/*') { true }

         %w[/directory /directory/extra/length].each do |path|
            expect(rule.match_path?(path)).to be false
         end
      end
   end

   describe '#rule_passes?' do
      it 'should raise an error if rule returns nonbool truthy value' do
         rule = Sinatra::Bouncer::Rule.new('/something') { 5 }

         expect { rule.rule_passes? }.to raise_error Sinatra::Bouncer::BouncerError
      end

      it 'should return true when the block is true' do
         rule = Sinatra::Bouncer::Rule.new('/something') { true }

         expect(rule.rule_passes?).to be true
      end

      it 'should return false when the block is false' do
         rule = Sinatra::Bouncer::Rule.new('/something') { false }

         expect(rule.rule_passes?).to be false
      end

      it 'should return false when the block is falsey' do
         rule = Sinatra::Bouncer::Rule.new('/something') { nil }

         expect(rule.rule_passes?).to be false
      end
   end
end
