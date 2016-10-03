Feature: Developer defines legal routes
   As a developer
   So that clients can safely access my server
   I will allow specific routes

   Scenario Outline: it should allows access to whitelist routes
      Given a sinatra server with bouncer and routes:
         | method | path   | allowed |
         | get    | <path> | yes     |
      When I visit "/<path>"
      Then it should be at "/<path>"
      And it should have status code 200
      Examples:
         | path         |
         | some_path    |
         | another_path |

   Scenario: it should NOT allow access to other routes
      Given a sinatra server with bouncer and routes:
         | method | path         | allowed |
         | get    | some_path    | yes     |
         | get    | illegal_path | no      |
      When I visit "/illegal_path"
      Then it should have status code 403

   Scenario Outline: it should allow multiple routes with a splat
      Given a sinatra server with bouncer and routes:
         | method | path    | allowed |
         | get    | admin/* | yes     |
      When I visit "/admin/<sub_path>"
      Then it should be at "/admin/<sub_path>"
      And it should have status code 200
      Examples:
         | sub_path  |
         | dashboard |
         | users     |

   Scenario Outline: it should allow splat to be in the middle of the route
      Given a sinatra server with bouncer and routes:
         | method | path           | allowed |
         | get    | admin/*/create | yes     |
      When I visit "/admin/<sub_path>/create"
      Then it should be at "/admin/<sub_path>/create"
      And it should have status code 200
      Examples:
         | sub_path |
         | tasks    |
         | users    |

   Scenario: it should forget rules between requests
      Given a sinatra server with bouncer and routes:
         | method | path      | allowed |
         | get    | some_path | once    |
      When I double visit "/some_path"
      Then it should be at "/some_path"
      And it should have status code 403