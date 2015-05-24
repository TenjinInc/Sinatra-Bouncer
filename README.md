#Sinatra::Bouncer
Simple authorization permissions extension for Sinatra. 

## Installation

**Prerequisites**

Bouncer requires [Sinatra](http://www.sinatrarb.com/), and [ruby 1.9.3](https://www.ruby-lang.org/en/documentation/installation/).  

**Gemfile**
```ruby
gem 'sinatra-bouncer'
```

**Command Line**
```sh
gem install sinatra-bouncer
```

##Usage
###Step 1: Require/Register Bouncer

**Sinatra Classic**
```ruby
require 'sinatra'
require 'sinatra/bouncer'

# ... routes and other config
```

**Modular**
```ruby
require 'sinatra/base'
require 'sinatra/bouncer'

class MyApp < Sinatra::Base
  register Sinatra::Bouncer
  
  # ... routes and other config
end
```

###Step 2: Declare Bouncer Rules

#### allow
Bouncer is stored in Sinatra's `settings` object, under `settings.bouncer`.

By default, Bouncer will reject any request that either:
* has no rule associated with it, or
* has no associated rule that returns `true`

Declare rules by calling `bouncer.allow` and providing a rule block. Rule blocks **must return an explicit boolean** (ie. `true` or `false`) to avoid any accidental truthy values creating unwanted access. 

```ruby
bouncer.allow('/user_posts_blog') do
    # calculate and return some boolean result
end
```

####allow(:all)
`allow(:all)` will match any path. 

```ruby
allow(:all) do
    # assuming a current_user helper to load the user object (like with warden)
    current_user.admin?
end
```

####always_allow
`always_allow(...)` is shorthand for `allow(..) { true }`. 

```ruby
  always_allow('/login') # Anyone can access this path
```

###Customization
The default bounce acion is to `halt 401`. Call `bounce_with` with a block that takes the sinatra application to change that behaviour. 

**Example**
```ruby
bounce_with do |application|
  application.redirect '/login'
end
```
