Given(/^a sinatra server with bouncer and routes:$/) do |table|
  app = Capybara.app

  allowed_paths = []

  table.hashes.each do |row|
    path = row[:path]
    path = "/#{path}" if path[0] != '/' # ensure leading slash

    method = row[:method].to_sym
    # build the routes
    app.send(method, path) do
      'The result of path'
    end

    if row[:allowed] =~ /yes|y|true/i
      allowed_paths << path

      # app.settings.bouncer.can(:get, path)
    end
  end

  app.rules do
    can(:any_method, allowed_paths) if allowed_paths

  end
end