# frozen_string_literal: true

When(/^I double visit "(.*?)"/) do |path|
   visit path
   visit '/'
   visit path
end

When(/^I visit "(.*?)"$/) do |path|
   visit path
end
