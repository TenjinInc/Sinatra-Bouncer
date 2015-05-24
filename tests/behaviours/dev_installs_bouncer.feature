Feature: Developer installs Bouncer
  As a developer
  So that I can secure my sinatra server
  I will install bouncer

  Scenario: Bouncer auto protects routes
    Given a sinatra server with bouncer and routes:
      | type | path      |
      | get  | some_path |
    When I visit "some_path"
    Then it should have status code 403

  Scenario: Bouncer bounces with given block
    Given a sinatra server with bouncer and routes:
      | type | path      | allowed |
      | get  | some_path | no      |
      | get  | login     | yes     |
    And bounce_with redirects to "/login"
    When I visit "some_path"
    Then it should have status code 200
    Then it should be at "/login"

  Scenario: Bouncer allows one path with a rule
    Given a sinatra server with bouncer and routes:
      | type | path            | allowed |
      | get  | some_path       | yes     |
      | get  | a_different_one | no      |
    When I visit "/some_path"
    Then it should be at "/some_path"
    Then it should have status code 200

  Scenario: Bouncer allows many paths with a rule
    Given a sinatra server with bouncer and routes:
      | type | path             |
      | get  | /some_path       |
      | get  | /a_different_one |
    And Bouncer allows these routes with one rule:
      | path             |
      | /some_path       |
      | /a_different_one |
    When I visit "/some_path"
    Then it should be at "/some_path"
    Then it should have status code 200

  Scenario: Bouncer blanket allows many paths with a rule
    Given a sinatra server with bouncer and routes:
      | type | path             |
      | get  | /some_path       |
    And Bouncer always allows these routes:
      | path             |
      | /some_path       |
    When I visit "/some_path"
    Then it should be at "/some_path"
    Then it should have status code 200

  Scenario Outline: Bouncer allows all paths with a rule
    Given a sinatra server with bouncer and routes:
      | type | path             |
      | get  | /some_path       |
      | get  | /a_different_one |
    And Bouncer allows all routes with one rule
    When I visit "<path>"
    Then it should be at "<path>"
    Then it should have status code 200
  Examples:
    | path             |
    | /some_path       |
    | /a_different_one |