require_relative 'rule'

module Sinatra
   module Bouncer
      class BasicBouncer
         attr_accessor :bounce_with
         attr_accessor :rules_initializer

         def initialize
            # @rules = Hash.new do |method_to_paths, method|
            #    method_to_paths[method] = Hash.new do |path_to_rules, path|
            #       path_to_rules[path] = []
            #    end
            # end

            @ruleset           = Hash.new do
               []
            end
            @rules_initializer = Proc.new {}
         end

         def reset!
            @ruleset.clear
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
               instance.instance_exec &bounce_with
            else
               instance.halt 403
            end
         end
      end

      class BouncerError < StandardError

      end
   end
end