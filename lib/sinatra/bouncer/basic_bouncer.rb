# frozen_string_literal: true

require_relative 'rule'

module Sinatra
   module Bouncer
      class BasicBouncer
         attr_accessor :bounce_with, :rules_initializer

         def initialize
            # @rules = Hash.new do |method_to_paths, method|
            #    method_to_paths[method] = Hash.new do |path_to_rules, path|
            #       path_to_rules[path] = []
            #    end
            # end

            @ruleset = Hash.new do
               []
            end

            @rules_initializer = proc {}
         end

         def reset!
            @ruleset.clear
         end

         def can(method, *paths)
            if block_given?
               hint = 'If you wish to conditionally allow, use #can_sometimes instead.'
               raise BouncerError, "You cannot provide a block to #can. #{ hint }"
            end

            can_sometimes(method, *paths) do
               true
            end
         end

         def can_sometimes(method, *paths, &block)
            unless block
               hint = 'If you wish to always allow, use #can instead.'
               raise BouncerError, "You must provide a block to #can_sometimes. #{ hint }"
            end

            paths.each do |path|
               @ruleset[method] += [Rule.new(path, &block)]
            end
         end

         def can?(method, path)
            rules = (@ruleset[:any_method] + @ruleset[method]).select { |rule| rule.match_path?(path) }

            rules.any? do |rule_block|
               ruling = rule_block.rule_passes?

               ruling
            end
         end

         def bounce(instance)
            if bounce_with
               instance.instance_exec(&bounce_with)
            else
               instance.halt 403
            end
         end
      end

      class BouncerError < StandardError
      end
   end
end
