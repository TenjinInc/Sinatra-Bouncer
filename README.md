# Sinatra-Bouncer

Simple permissions extension for [Sinatra](http://www.sinatrarb.com/). Require the gem, then declare which
routes are permitted based on your own logic.

## Big Picture

Bouncer's syntax looks like:

```ruby
# You can define roles to collect permissions together
role :admins do
   current_user&.admin?
end

rules do
   # Routes match based on one or more strings. 
   anyone.can get:  '/',
              post: ['/user/sign-in',
                     '/user/sign-out']

   # Wildcards match anything directly under that path 
   anyone.can get: '/lib/js/*'

   admins.can get:  '/admin/*',
              post: '/admin/actions/*'

   # ... etc ...
end
```

### Features

Here's what this Gem provides:

* **Block-by-default**
    * Any route must be explicitly allowed
* **Role-Oriented**
    * The [DSL](https://en.wikipedia.org/wiki/Domain-specific_language) is constructed to be easily readable
* **Declarative Syntax**
    * Straightforward syntax reduces complexity of layered permissions
    * Keeps permissions together for clarity
* **Conditional Logic Via Blocks**
    * Often additional checks must be performed to know if a route is allowed.
* **Grouping**
    * Routes can be matched by wildcard
* **Forced Boolean Affirmation**
    * Condition blocks must explicitly return `true`, avoiding accidental truthy values

### Anti-Features

Bouncer intentionally does not support some concepts.

* **No User Identification** *(aka Authentication)*
    * Bouncer is not a user identification gem. It assumes you already have an existing solution
      like [Warden](https://github.com/wardencommunity/warden). Knowing *who* someone is is already a complex enough
      problem and should be separate from what they may do.
* **No Rails Integration**
    * Bouncer is not intended to work with Rails. Use one of the Rails-based permissions gems for these situations.
* **No Negation**
    * There is intentionally no negation (eg. `cannot`) to preserve the default-deny frame of mind

## Installation

Add this to your gemfile:

```ruby
gem 'sinatra-bouncer'
```

Then run:

```shell
bundle install
```

**Sinatra Modular Style**

```ruby
require 'sinatra/base'
require 'sinatra/bouncer'

class MyApp < Sinatra::Base
   register Sinatra::Bouncer

   rules do
      # ... can statements ...
   end

   # ... routes and other config
end
```

**Sinatra Classic Style**

```ruby
require 'sinatra'
require 'sinatra/bouncer'

rules do
   # ... can statements ...
end

# ... routes and other config
```

## Usage

Define roles using the `role` method and provide each one with a condition block. Then call `rules` with a block that
uses your defined roles with the `#can` or `#can_sometimes` DSL methods to declare which
paths are allowed.

The rules block is run once as part of the configuration phase but the condition blocks are evaluated in the context of
the request. This means they have access to Sinatra helpers, the `request` object, and `params`.

```ruby
require 'sinatra'
require 'sinatra/bouncer'

role :members do
   !current_user.nil?
end

role :bots do
   !request.get_header('X-CUSTOM-BOT').nil?
end

rules do
   # example: always allow GET requests to '/' and '/about'; and POST requests to '/sign-in'
   anyone.can get:  ['/', '/about'],
              post: '/sign-in'

   # example: logged in users can view (GET) member restricted paths and edit their account (POST)
   members.can get: '/members/*'
   members.can_sometimes post: '/members/edit-account' do
      current_user && current_user.id == params[:id]
   end

   # example: require presence of arbitrary request header in the role condition
   bots.can get: '/bots/*'
end

# ... Sinatra route declarations as normal ... 
```

### Role Declarations

Roles are declared using the `#role` method in your Sinatra config. Each one must be provided a condition block that
must return exactly `true` when the role applies.

```ruby
# let's pretend that current_user is a helper that returns the user from Warden
role :admins do
   current_user&.admin?
end
```

> **Note:** There is a default role called `anyone` that is always declared for you.

### HTTP Method and Route Matching

Both `#can` and `#can_sometimes` accept symbol
[HTTP methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods) as keys
and each key is paired with one or more path strings.

```ruby
# example: single method, single route 
anyone.can get: '/'

# example: multiple methods, single route each 
anyone.can get:  '/',
           post: '/blog/action/save'

# example: multiple methods, multiple routes (using string array syntax)
anyone.can get:  %w[/
                    /sign-in
                    /blog/editor],
           post: %w[/blog/action/save 
                    /blog/action/delete]
```

> **Note** Allowing GET implies allowing HEAD, since HEAD is by spec a GET without a response body. The reverse is not
> true, however; allowing HEAD will not also allow GET.

#### Wildcards and Special Symbols

Provide a wildcard `*` to match any string excluding slash. There is intentionally no syntax for matching wildcards
recursively, so nested paths will also need to be declared.

```ruby
# example: match anything directly under the /members/ path
members.can get: '/members/*'
```

There is also a special symbol, `:all` that matches all paths. It is intended for rare use
with superadmin-type accounts.

```ruby
# this allows GET on all paths to those in the admin group
admins.can get: :all
```

> **Warning** Always be cautious when using wildcards and special symbols to avoid accidentally opening up pathways that
> should remain private.

### Always Allow: `can`

Any route declared with `#can` will be accepted without further challenge.

```ruby
rules do
   # Anyone can access this path over GET
   anyone.can get: '/login'
end
```

### Conditionally Allow: `can_sometimes`

`can_sometimes` takes a condition block that will be run once the path is attempted. This block **must return an
explicit boolean** (ie. `true` or `false`) to avoid any accidental truthy values creating unwanted access.

```ruby
role :users do
   !current_user.nil?
end

rules do
   users.can_sometimes post: '/user/save' do
      current_user.id == params[:id]
   end
end
```

### Custom Bounce Behaviour

The default bounce action is to `halt 403`. Call `bounce_with` with a block to specify your own behaviour. The block is
also run in a sinatra request context, so you can use helpers here as well.

```ruby
require 'sinatra'
require 'sinatra/bouncer'

bounce_with do
   redirect '/login'
end

# bouncer rules, routes, etc...
```

## Alternatives

The syntax for Bouncer is largely influenced by the now-deprecated [CanCan](https://github.com/ryanb/cancan) gem.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TenjinInc/Sinatra-Bouncer.

Valued topics:

* Error messages (clarity, hinting)
* Documentation
* API
* Security correctness

This project is intended to be a friendly space for collaboration, and contributors are expected to adhere to the
[Contributor Covenant](https://www.contributor-covenant.org/) code of conduct. Play nice.

### Core Developers

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests. You
can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Documentation is produced by Yard. Run `bundle exec rake yard`. The goal is to have 100% documentation coverage and 100%
test coverage.

Release notes are provided in `RELEASE_NOTES.md`, and should vaguely
follow [Keep A Changelog](https://keepachangelog.com/en/1.0.0/) recommendations.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/license/mit/).
