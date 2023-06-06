# frozen_string_literal: true

Then(/^it should have status code (\d+)$/) do |status|
   # save_and_open_page
   expect(page.driver.status_code).to eq status.to_i
end

Then(/^it should be at "(.*?)"$/) do |path|
   expect(page).to have_current_path path
end
