# frozen_string_literal: true

module Sinatra
   module Bouncer
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

         def rule_passes?
            ruling = @rule.call

            unless ruling.is_a?(TrueClass) || ruling.is_a?(FalseClass)
               source = @rule.source_location.join(':')
               msg    = <<~ERR
                  Rule block at does not return explicit true/false.
                  Rules must return explicit true or false to prevent accidental truthy values.
                  Source: #{ source }
               ERR

               raise BouncerError, msg
            end

            ruling
         end
      end
   end
end
