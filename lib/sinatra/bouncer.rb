# frozen_string_literal: true

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

require 'sinatra/base'
require_relative 'bouncer/basic_bouncer'

# Namespace module
module Sinatra
   # Namespace module
   module Bouncer
      def self.registered(base_class)
         base_class.set :bouncer, BasicBouncer.new

         base_class.before do
            http_method = request.request_method.downcase.to_sym
            path        = request.path.downcase

            settings.bouncer.bounce(self) unless settings.bouncer.can?(http_method, path, self)
         end
      end

      def bounce_with(&block)
         bouncer.bounce_with(&block)
      end

      def role(identifier, &block)
         settings.bouncer.role identifier, &block
      end

      def rules(...)
         settings.bouncer.rules(...)
      end
   end

   register Sinatra::Bouncer
end
