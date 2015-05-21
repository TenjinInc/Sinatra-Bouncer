Then(/^it should have status code (\d+)$/) do |status|
  # save_and_open_page
  page.driver.status_code.should == status.to_i
end

Then(/^it should be at "(.*?)"$/) do |path|
  page.current_path.should == path
end

Then(/^it should have raised an exception$/) do
  @exception.should_not be_nil
  @exception.class.should == Sinatra::Bouncer::BouncerError
end