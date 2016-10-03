Feature: Developer installs Bouncer
   As a developer
   So that I can secure my sinatra server
   I will install bouncer

   Scenario: it should auto protect all routes
      Given a sinatra server with bouncer and routes:
         | method | path      |
         | get    | some_path |
      When I visit "some_path"
      Then it should have status code 403