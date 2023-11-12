# frozen_string_literal: true

require_relative 'rule'

module Sinatra
   module Bouncer
      class BasicBouncer
         attr_accessor :bounce_with, :rules_initializer

         # Enumeration of HTTP method strings based on:
         #    https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
         # Ignoring CONNECT and TRACE due to rarity
         HTTP_METHODS = %w[GET HEAD PUT POST DELETE OPTIONS PATCH].freeze

         # Symbol versions of HTTP_METHODS constant
         #
         # @see HTTP_METHODS
         HTTP_METHOD_SYMBOLS = HTTP_METHODS.collect do |http_method|
            http_method.downcase.to_sym
         end.freeze

         # Method symbol used to match any method
         WILDCARD_METHOD = :any

         def initialize
            @ruleset = Hash.new do
               []
            end

            @rules_initializer = proc {}
         end

         def reset!
            @ruleset.clear
         end

         def can(method_routes)
            if block_given?
               hint = 'If you wish to conditionally allow, use #can_sometimes instead.'
               raise BouncerError, "You cannot provide a block to #can. #{ hint }"
            end

            can_sometimes(**method_routes) do
               true
            end
         end

         def can_sometimes(**method_routes, &block)
            unless block
               hint = 'If you wish to always allow, use #can instead.'
               raise BouncerError, "You must provide a block to #can_sometimes. #{ hint }"
            end

            method_routes.each do |method, paths|
               unless HTTP_METHOD_SYMBOLS.include?(method) || method == WILDCARD_METHOD
                  raise BouncerError,
                        "'#{ method }' is not a known HTTP method key. Must be one of: #{ HTTP_METHOD_SYMBOLS } or :#{ WILDCARD_METHOD }"
               end

               paths = [paths] unless paths.respond_to? :collect

               @ruleset[method] += paths.collect { |path| Rule.new(path, &block) }
            end
         end

         def can?(method, path)
            rules = (@ruleset[WILDCARD_METHOD] + @ruleset[method]).select { |rule| rule.match_path?(path) }

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
