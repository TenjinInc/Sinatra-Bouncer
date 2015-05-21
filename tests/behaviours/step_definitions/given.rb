Given(/^a sinatra server with bouncer and routes:$/) do |table|
  app = Capybara.app

  table.hashes.each do |row|
    path = row[:path]

    path = "/#{path}" if path[0] != '/'

    app.send(row[:type.to_sym], path) do
      'The result of path'
    end

    if row[:allowed] =~ /yes|y|true/i
      app.settings.bouncer.allow(path) do
        true
      end
    end
  end
end

Given(/^bounce_with redirects to "(.*?)"$/) do |path|
  Capybara.app.bounce_with do |instance|
    instance.redirect path
  end
end

Given(/^Bouncer allows these routes with one rule:$/) do |table|
  app = Capybara.app

  paths = table.hashes.collect do |row|
    row[:path]
  end

  app.settings.bouncer.allow(paths) do
    true
  end
end

Given(/^Bouncer allows all routes with one rule$/) do
  app = Capybara.app

  app.settings.bouncer.allow(:all) do
    true
  end
end