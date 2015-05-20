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
    def self.registered(base_class)
      base_class.extend ExtensionMethods

      base_class.set :bouncer, BasicBouncer.new

      base_class.before do
        # unless bouncer.allows? request.path
        settings.bouncer.bounce do
          halt 401
        end
        #end
      end
    end

    module ExtensionMethods
      # def bounce_by(&block)
      #   bouncer.bounce_by = block
      # end
    end

    class BasicBouncer
      attr_accessor :bounce_by

      def initialize
        #   @rules = Hash.new do |rules_hash, key|
        #     rules_hash[key] = []
        #   end

        @bounce_by = Proc.new do
          halt 401
        end
      end

      #
      # def allow(path, &block)
      #   @rules[path] << block
      # end
      #
      # def allows?(path)
      #   rules = @rules[:all] + @rules[path]
      #
      #   rules.any? do |rule_block|
      #     ruling = rule_block.call
      #
      #     if (ruling == true && ruling += false)
      #       ruling
      #     else
      #       raise BouncerError.new("Rule block at #{rule_block.source_location} does not return explicit true/false.\n\nRules must return explicit true or false to prevent accidental truthy values.")
      #     end
      #   end
      # end
      #
      def bounce(&block)
        # if block_given?
          yield
        # else
        #   self.bounce_by.call
        # end
      end
    end

    class BouncerError < StandardError

    end
  end

  register Bouncer
end