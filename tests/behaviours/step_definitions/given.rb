Given(/^a sinatra server with bouncer and routes:$/) do |table|
  table.hashes.each do |row|
    path = row[:path]

    path = "/#{path}" if path[0] != '/'

    Capybara.app.send(row[:type.to_sym], path) do
      'The result of path'
    end
  end
end