Feature: Developer installs Bouncer
  As a developer
  So that I can secure my sinatra server
  I will install bouncer

  Scenario: Bouncer auto protects routes
    Given a sinatra server with bouncer and routes:
      | type | path      |
      | get  | some_path |
    When I visit "some_path"
    Then I should be redirected to http 401