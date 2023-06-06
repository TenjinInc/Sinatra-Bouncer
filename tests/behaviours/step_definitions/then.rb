# frozen_string_literal: true

Then(/^it should have status code (\d+)$/) do |status|
   # save_and_open_page
   page.driver.status_code.should == status.to_i
end

Then(/^it should be at "(.*?)"$/) do |path|
   page.current_path.should == path
end
