Feature: Developer installs Bouncer
  As a developer
  So that I can secure my sinatra server
  I will install bouncer

  Scenario: Bouncer auto protects routes
    Given a sinatra server with bouncer and routes:
      | method | path      |
      | get    | some_path |
    When I visit "some_path"
    Then it should have status code 403

  Scenario: Bouncer allows one path with a rule
    Given a sinatra server with bouncer and routes:
      | method | path            | allowed |
      | get    | some_path       | yes     |
      | get    | a_different_one | no      |
    When I visit "/some_path"
    Then it should be at "/some_path"
    Then it should have status code 200