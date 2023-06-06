# frozen_string_literal: true

Given(/^a sinatra server with bouncer and routes:$/) do |table|
   app = Capybara.app

   allowed_paths = []

   table.hashes.each do |row|
      path = row[:path]
      path = "/#{ path }" if path[0] != '/' # ensure leading slash

      method = row[:method].to_sym
      # build the routes
      app.send(method, path) do
         'The result of path'
      end

      if row[:allowed] =~ /yes|y|true|once/i
         allowed_paths << path
      end

      if row[:allowed] =~ /once/i
         @allowed_once_paths << path
      end
   end

   onces = @allowed_once_paths

   app.rules do
      allowed_paths.each do |path|
         can_sometimes(:any_method, path) do
            !onces.include?(path)
         end
      end
   end
end
