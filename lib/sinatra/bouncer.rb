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
      base_class.set :bouncer, BasicBouncer.new

      base_class.before do
        unless settings.bouncer.allows? request.path, self
          settings.bouncer.bounce(self)
        end
      end
    end

    def bounce_with(&block)
      bouncer.bounce_with = block
    end

    class BasicBouncer
      attr_accessor :bounce_with

      def initialize
        @rules = Hash.new do |rules_hash, key|
          rules_hash[key] = []
        end
      end

      def always_allow(paths)
        self.allow(paths) do
          true
        end
      end

      def allow(paths, &block)
        unless block
          raise Sinatra::Bouncer::BouncerError.new('You must provide a block to #allow. If you wish to always allow, either return true or use #always_allow instead')
        end

        paths = [paths] unless paths.is_a? Array

        paths.each do |path|
          @rules[path] << block
        end
      end

      def allows?(path, app)
        rules = @rules[:all] + @rules[path]

        # rules = @rules[path]

        rules.any? do |rule_block|
          ruling = rule_block.call(app)

          if ruling == true || ruling == false
            ruling
          else
            source = rule_block.source_location.join(':')
            raise BouncerError.new("Rule block at does not return explicit true/false.\n\n"+
                                       "Rules must return explicit true or false to prevent accidental truthy values.\n\n"+
                                       "Source: #{source}\n")
          end
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