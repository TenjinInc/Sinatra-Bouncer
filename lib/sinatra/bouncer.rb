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

module Sinatra
  module Bouncer
    def self.registered(base_class)
      base_class.helpers HelperMethods

      bouncer = BasicBouncer.new

      # TODO: can we instead store it somehow on the actual temp request object?
      base_class.set :bouncer, bouncer

      base_class.before do
        bouncer.reset! # must clear all rules otherwise will leave doors open

        self.instance_exec &bouncer.rules_initializer

        http_method = request.request_method.downcase.to_sym
        path = request.path.downcase

        unless bouncer.can?(http_method, path)
          bouncer.bounce(self)
        end
      end
    end

    # Start ExtensionMethods
    def bounce_with(&block)
      bouncer.bounce_with = block
    end

    def rules(&block)
      bouncer.rules_initializer = block
    end

    # End ExtensionMethods

    module HelperMethods
      def can(*args)
        settings.bouncer.can(*args)
      end

      def can_sometimes(*args, &block)
        settings.bouncer.can_sometimes(*args, &block)
      end
    end

    # Data class
    class BasicBouncer
      attr_accessor :bounce_with
      attr_accessor :rules_initializer

      def initialize
        @rules = Hash.new do |method_to_paths, method|
          method_to_paths[method] = Hash.new do |path_to_rules, path|
            path_to_rules[path] = []
          end
        end

        @rules_initializer = Proc.new {}
      end

      def reset!
        @rules.clear
      end

      def can(method, *paths)
        if block_given?
          raise BouncerError.new('You cannot provide a block to #can. If you wish to conditionally allow, use #can_sometimes instead.')
        end

        can_sometimes(method, *paths) do
          true
        end
      end

      def can_sometimes(method, *paths, &block)
        unless block_given?
          raise BouncerError.new('You must provide a block to #can_sometimes. If you wish to always allow, use #can instead.')
        end

        paths.each do |path|
          @rules[method][path] << block
        end
      end

      def can?(method, path)
        rules = @rules[:any_method][path] + @rules[method][:all] + @rules[method][path] #@rules[:all] + @rules[method]

        rules.any? do |rule_block|
          ruling = rule_block.call #(app)

          if ruling != true && ruling != false
            source = rule_block.source_location.join(':')
            raise BouncerError.new("Rule block at does not return explicit true/false.\n\n"+
                                       "Rules must return explicit true or false to prevent accidental truthy values.\n\n"+
                                       "Source: #{source}\n")
          end

          ruling
        end
      end

      def bounce(instance)
        if bounce_with
          bounce_with.call(instance)
        else
          instance.halt 403
        end
      end
    end

    class BouncerError < StandardError

    end
  end

  if defined? register
    register Bouncer
  end
end