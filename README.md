# Sinatra-Bouncer

Simple permissions extension for [Sinatra](http://www.sinatrarb.com/). Require the gem, then declare which
routes are permitted based on your own logic.

## Big Picture

Bouncer rules look like:

```ruby
rules do
   # Routes match based on one or more strings. 
   can get:  '/',
       post: %w[/user/sign-in
                /user/sign-out]

   # Wildcards match anything directly under that path 
   can get: '/lib/js/*'

   # Use a conditional rule block for additional logic
   can_sometimes get:  '/admin/*',
                 post: '/admin/actions/*' do
      current_user.admin?
   end

   # ... etc ...
end

```

## Features

Here's what this Gem provides:

* **Block-by-default**
    * Any route must be explicitly allowed
* **Declarative Syntax**
    * Straightforward syntax reduces complexity of layered permissions
    * Keeps permissions together for clarity
* **Conditional Logic Via Blocks**
    * Often additional checks must be performed to know if a route is allowed.
* **Grouping**
    * Routes can be matched by wildcard
* **Forced Boolean Affirmation**
    * Condition blocks must explicitly return `true`, avoiding accidental truthy values

## Anti-Features

Bouncer intentionally does not support some concepts.

* **No User Identification** *(aka Authentication)*
    * Bouncer is not a user identification gem. It assumes you already have an existing solution
      like [Warden](https://github.com/wardencommunity/warden). Knowing *who* someone is is already a complex enough
      problem and should be separate from what they may do.
* **No Rails Integration**
    * Bouncer is not intended to work with Rails. Use one of the Rails-based permissions gems for these situations.

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

   # ... routes and other config
end
```

**Sinatra Classic Style**

```ruby
require 'sinatra'
require 'sinatra/bouncer'

# ... routes and other config
```

## Usage

Call `rules` with a block that uses the `#can` and `#can_sometimes` DSL methods to declare rules for paths.

The rules block is run in the context of the request, which means you will have access to sinatra helpers,
the `request` object, and `params`.

```ruby
require 'sinatra'
require 'sinatra/bouncer'

rules do
   # example: allow any GET request
   can get: :all

   # example: logged in users can edit their account
   can_sometimes post: '/user_edits_account' do
      current_user
   end
end

# ... route declarations as normal below
```

## API

### Always Allow: `can`

Any route declared with #can will be accepted without further challenge.

```ruby
rules do
   can post: '/user/blog/actions/save' # Always allow access to this path over GET
end
```

### #can_sometimes

`can_sometimes` is for occasions that you to check further, but want to defer that choice until the path is actually
attempted.
`can_sometimes` takes a block that will be run once the path is attempted. This block **must return an explicit boolean
**
(ie. `true` or `false`) to avoid any accidental truthy values creating unwanted access.

```ruby
rules do
   can_sometimes get: '/login' # Anyone can access this path over GET
end
```

#### :any and :all special parameters

Passing `can` or `can_sometimes`:

* `:any` to the first parameter will match any HTTP method.
* `:all` to the second parameter will match any path.

```ruby
# this allows get on all paths
can get: :all

# this allows any method type on the / path
can any: '/'
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
