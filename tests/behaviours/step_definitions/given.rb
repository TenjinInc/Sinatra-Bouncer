Given(/^a sinatra server with bouncer and routes:$/) do |table|
  app = Capybara.app

  table.hashes.each do |row|
    path = row[:path]
    path = "/#{path}" if path[0] != '/' # ensure leading slash

    method = row[:method].to_sym
    # build the routes
    app.send(method, path) do
      'The result of path'
    end

    if row[:allowed] =~ /yes|y|true/i
      app.settings.bouncer.can(:get, path)
    end
  end
end