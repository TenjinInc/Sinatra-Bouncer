# frozen_string_literal: true

When 'he/she/they/I double visit(s) {path}' do |path|
   visit path
   visit '/'
   visit path
end

When 'he/she/they/I visit(s) {path}' do |path|
   visit path
end
