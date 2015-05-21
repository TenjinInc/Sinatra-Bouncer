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
```bash
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

Bouncer is stored in Sinatra's `settings` object, under `settings.bouncer`.

By default, Bouncer will reject any request that doesn't have a rule associated with it.
Declare rules by calling `allow` on Bouncer, and providing a rule block. Rule blocks must 
`always_allow(...)` is shorthand for `allow(..) { true }`. 

```ruby
bouncer.allow('/user_posts_blog') do
    # calculate and return some boolean result
end
```

```ruby
allow(:all) do
    # assuming a current_user helper to load the user object (like with warden)
    current_user.admin?
end
```

```ruby
always_allow('user_performs_action') # Anyone can access this path
```

###Customization
The default bounce acion is to `halt 401`. Call `bounce_with` with a block to change that behaviour. 
