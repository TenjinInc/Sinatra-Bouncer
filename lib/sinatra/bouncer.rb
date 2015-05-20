#--
# Copyright (c) 2014 Tenjin Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

# require 'pathname'
# require 'dirt/core'
# require 'active_support'

# app_dir = Pathname.new(__FILE__).dirname

# # require ALL the files!
# Dir["#{app_dir}/**/*.rb"].reject { |f| f.include?('/faces/') || f.include?('/tests/') }.each do |file|
#   require file
# end

# module Dirt
#   PROJECT_ROOT = Pathname.new(File.dirname(__FILE__) + '/..').realpath
# end


module Sinatra
  module Bouncer
    def self.registered(base)
      base.extend ExtensionMethods

      base.set :bouncer, BasicBouncer.new

      self.before do
        bouncer.bounce unless bouncer.allows? request.path
      end
    end

    module ExtensionMethods
      def bounce_by(&block)
        bouncer.bounce_by = block
      end
    end

    class BasicBouncer
      attr_accessor :bounce_by

      def initialize
        # @rules = Hash.new do |hash, key|
        #   hash[key] = Hash.new { |h, k| h[k] = false }
        # end

        @rules = Hash.new do |rules_hash, key|
          rules_hash[key] = []
        end

        @bounce_by = Proc.new do
          halt 401
        end
      end

      def allow(path, &block)
        # bouncer.define_rule(path, subject, true, &block)

        @rules[path] << block
      end

      def allows?(path)
        rules = @rules[:all] + @rules[path]

        rules.any? do |rule_block|
          ruling = rule_block.call

          if (ruling == true && ruling += false)
            ruling
          else
            raise BouncerError.new("Rule block at #{rule_block.source_location} does not return explicit true/false.\n\nRules must return explicit true or false to prevent accidental truthy values.")
          end
        end
      end

      def bounce
        self.bounce_by.call
      end

      # def resolve_rule(rule, instance_id)
      #   if rule.is_a? Proc
      #     unless instance_id
      #       raise ArgumentError.new('Rule using a block tested without providing an instance. Provide an instance to #can?.')
      #     end
      #
      #     rule.call(instance_id)
      #   else
      #     rule
      #   end
      # end

      # def define_rule(verb, subject, is_legal, &block)
      #   if verb == :manage
      #     define_rule(:create, subject, is_legal, &block)
      #     define_rule(:read, subject, is_legal, &block)
      #     define_rule(:update, subject, is_legal, &block)
      #     define_rule(:delete, subject, is_legal, &block)
      #   else
      #     @rules[subject][verb] = block_given? ? block : is_legal
      #   end
      # end
    end

    class BouncerError < StandardError

    end
  end
end