# frozen_string_literal: true

module Sinatra
   module Bouncer
      # Defines a Rule to be evaluated with each request
      class Rule
         def initialize(path, &rule_block)
            if path == :all
               @path = :all
            else
               path = "/#{ path }" unless path.start_with?('/')

               @path = path.split('/')
            end

            @rule = rule_block
         end

         # Determines if the path matches the exact path or wildcard.
         #
         # @return `true` if the path matches
         def match_path?(path)
            return true if @path == :all

            path = "/#{ path }" unless path.start_with?('/')

            split_path = path.split('/')
            matches    = @path.length == split_path.length

            @path.each_index do |i|
               allowed_segment = @path[i]
               given_segment   = split_path[i]

               matches &= given_segment == allowed_segment || allowed_segment == '*'
            end

            matches
         end

         # Evaluates the rule's block. Defensively prevents truthy values from the block from allowing a route.
         #
         # @raise BouncerError when the rule block is a truthy value but not exactly `true`
         # @return Exactly `true` or `false`, depending on the result of the rule block
         def rule_passes?
            ruling = @rule.call

            unless !ruling || ruling.is_a?(TrueClass)
               source = @rule.source_location.join(':')
               msg    = <<~ERR
                  Rule block at does not return explicit true/false.
                  Rules must return explicit true or false to prevent accidental truthy values.
                  Source: #{ source }
               ERR

               raise BouncerError, msg
            end

            !!ruling
         end
      end
   end
end
