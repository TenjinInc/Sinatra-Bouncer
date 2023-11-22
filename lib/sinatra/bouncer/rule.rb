# frozen_string_literal: true

module Sinatra
   module Bouncer
      # Defines a RuleSet to be evaluated with each request
      class Rule
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

         def initialize(&block)
            raise ArgumentError, 'must provide a block to Bouncer::Rule' unless block

            @routes = Hash.new do
               []
            end

            @conditions = [block]
         end

         def can_sometimes(**method_routes, &block)
            if method_routes.empty?
               raise ArgumentError,
                     'must provide a hash where keys are HTTP method symbols and values are one or more path matchers'
            end

            unless block
               hint = 'If you wish to always allow, use #can instead.'
               raise BouncerError, "You must provide a block to #can_sometimes. #{ hint }"
            end

            # TODO: enable chaining
            # clone = Rule.new(&@conditions.first)

            method_routes.each do |method, paths|
               validate_http_method! method

               paths = [paths] unless paths.respond_to? :collect

               @routes[method] += paths.collect { |path| normalize_path path }
            end

            @conditions << block

            # clone
         end

         def can(**method_routes)
            if block_given?
               hint = 'If you wish to conditionally allow, use #can_sometimes instead.'
               raise BouncerError, "You cannot provide a block to #can. #{ hint }"
            end

            can_sometimes(**method_routes) do
               true
            end
         end

         def allow?(method, path, context)
            match_path?(method, path) && @conditions.all? do |condition|
               rule_passes?(context, &condition)
            end
         end

         private

         def validate_http_method!(method)
            return if HTTP_METHOD_SYMBOLS.include?(method)

            raise BouncerError, "'#{ method }' is not a known HTTP method key. Must be one of: #{ HTTP_METHOD_SYMBOLS }"
         end

         # Determines if the path matches the exact path or wildcard.
         #
         # @return `true` if the path matches
         def match_path?(method, trial_path)
            trial_path = normalize_path trial_path

            matchers_for(method).any? do |matcher|
               return true if matcher == :all

               matcher_parts = matcher.split '/'
               trial_parts   = trial_path.split '/'
               matches       = matcher_parts.length == trial_parts.length

               matcher_parts.each_index do |i|
                  allowed_segment = matcher_parts[i]
                  given_segment   = trial_parts[i]

                  matches &= given_segment == allowed_segment || allowed_segment == '*'
               end

               matches
            end
         end

         def matchers_for(method)
            matchers = @routes[method]

            matchers += @routes[:get] if method == :head

            matchers
         end

         # Evaluates the rule's block. Defensively prevents truthy values from the block from allowing a route.
         #
         # @raise BouncerError when the rule block is a truthy value but not exactly `true`
         # @return Exactly `true` or `false`, depending on the result of the rule block
         def rule_passes?(context, &rule)
            ruling = context.instance_exec(&rule)

            unless !ruling || ruling.is_a?(TrueClass)
               source = rule.source_location.join(':')
               msg    = <<~ERR
                  Rule block at does not return explicit true/false.
                  Rules must return explicit true or false to prevent accidental truthy values.
                  Source: #{ source }
               ERR

               raise BouncerError, msg
            end

            !!ruling
         end

         def normalize_path(path)
            if path == :all || path.start_with?('/')
               path
            else
               "/#{ path }"
            end
         end
      end
   end
end
