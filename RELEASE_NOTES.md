# Release Notes

All notable changes to this project will be documented below.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project loosely follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Major Changes

* none

### Minor Changes

* none

### Bugfixes

* none

## [3.0.0] - 2023-11-21

### Major Changes

* Changed rules DSL to be role-oriented
* Removed the `:any` HTTP method wildcard
* Changed Sinatra API to require calling methods on bouncer object
    * eg. `rules do ... end` should now be `bouncer.rules do ... end`

### Minor Changes

* none

### Bugfixes

* none

## [2.0.0] - 2023-11-13

### Major Changes

* Converted to hash syntax in `can` and `can_sometimes` statements

### Minor Changes

* Converted Cucumber tests to Rspec integration tests for consistency
* HEAD requests are evaluated like GET requests due to semantic equivalence
* Falsey values are now acceptable rule block results

### Bugfixes

* none

## [1.3.0] - 2023-09-13

### Major Changes

* none

### Minor Changes

* Increased minimum Ruby to 3.1
* Cleaned up development dependencies
* Rubocop cleanups
* Installed Simplecov
* Created Rakefile

### Bugfixes

* none

## [1.2.0] - 2016-10-02

### Major Changes

* none

### Minor Changes

* Supports wildcard matches in route strings

### Bugfixes

* none

## [1.1.1] - 2015-06-02

### Major Changes

* none

### Minor Changes

* none

### Bugfixes

* Runs `bounce_with` in context of web request

## [1.1.0] - 2015-05-28

### Major Changes

* none

### Minor Changes

* none

### Bugfixes

* Correctly forgets rules between routes

## [1.0.2] - 2015-05-24

### Major Changes

* none

### Minor Changes

* Changed default halt to 403
* Application available in rule block

### Bugfixes

* Fixed sinatra module registration

## [1.0.1] - 2015-05-21

### Major Changes

* none

### Minor Changes

* none

### Bugfixes

* none

## [1.0.0] - Unreleased Prototype

### Major Changes

* none

### Minor Changes

* none

### Bugfixes

* none

## [0.1.0] - Unreleased Prototype

### Major Changes

* Initial prototype

### Minor Changes

* none

### Bugfixes

* none
