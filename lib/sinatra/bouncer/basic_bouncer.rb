# frozen_string_literal: true

require_relative 'rule'

module Sinatra
   module Bouncer
      # Core implementation of Bouncer logic
      class BasicBouncer
         attr_accessor :bounce_with, :rules_initializer

         def initialize
            @rules = []

            role :anyone do
               true
            end

            @rules_initializer = proc {}
         end

         def rules(&block)
            instance_exec(&block)
            @rules.each do |rule|
               raise BouncerError, 'rules block error: missing #can or #can_sometimes call' if rule.incomplete?
            end
         end

         def can?(method, path, context)
            @rules.any? do |rule|
               rule.allow? method, path, context
            end
         end

         def bounce(instance)
            if bounce_with
               instance.instance_exec(&bounce_with)
            else
               instance.halt 403
            end
         end

         def role(identifier, &block)
            raise ArgumentError, 'must provide a role identifier to #role' unless identifier
            raise ArgumentError, 'must provide a role condition block to #role' unless block
            raise ArgumentError, "role called '#{ identifier }' already defined" if respond_to? identifier

            define_singleton_method identifier do
               add_rule(&block)
            end
         end

         private

         def add_rule(&block)
            rule = Rule.new(&block)
            @rules << rule
            rule
         end
      end

      class BouncerError < StandardError
      end
   end
end
