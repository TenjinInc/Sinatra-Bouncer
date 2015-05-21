Feature: Developer installs Bouncer
  As a developer
  So that I can secure my sinatra server
  I will install bouncer

  Scenario: Bouncer auto protects routes
    Given a sinatra server with bouncer and routes:
      | type | path      |
      | get  | some_path |
    When I visit "some_path"
    Then it should have status code 401

  Scenario: Bouncer bounces with given block
    Given a sinatra server with bouncer and routes:
      | type | path      | allowed |
      | get  | some_path | no      |
      | get  | login     | yes     |
    And bounce_with redirects to "/login"
    When I visit "some_path"
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
      | type | path            |
      | get  | /some_path       |
      | get  | /a_different_one |
    And Bouncer allows these routes with one rule:
      | path             |
      | /some_path       |
      | /a_different_one |
    When I visit "/some_path"
    Then it should be at "/some_path"
    Then it should have status code 200


  it 'should raise an exception when a rule block returns anything but explicit true or false'
  it 'should apply the rule to all routes when :all is supplied as the path'