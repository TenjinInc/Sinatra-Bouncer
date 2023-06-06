# frozen_string_literal: true

Then 'it should have status code {int}' do |status|
   expect(page.driver.status_code).to eq status
end

Then 'it should be at {path}' do |path|
   expect(page).to have_current_path path.to_s
end
