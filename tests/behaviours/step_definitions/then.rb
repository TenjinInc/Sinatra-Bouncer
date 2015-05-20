Then(/^I should be redirected to http (\d+)$/) do |status|
  # save_and_open_page
  page.driver.status_code.should == status.to_i

end