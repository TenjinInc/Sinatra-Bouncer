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

After registration, Bouncer will reject any request that either:
* has no rule associated with it, or
* has no associated rule that returns `true`

###Step 2: Declare Bouncer Rules
Call `rules` with a block that uses `can` and `can_sometimes` to declare which paths legal. 
The rules block is run in the context of the request, which means you will have access to sinatra helpers, 
the `request` object, and `params`.

**Example**
```ruby
require 'sinatra'
require 'sinatra/bouncer'

rules do
  can(:get, :all)
  
  # logged in users can edit their account
  if(current_user)
    can(:post, '/user_edits_account')
  end
end

# ... route declarations as normal below
```

#### can
Any route declared with #can will be accepted this request without further challenge. 

```ruby
rules do
   can(:post, '/user_posts_blog')
end
```

####can_sometimes
`can_sometimes` is for occasions that you to check further, but want to defer that choice until the path is actually attempted.
`can_sometimes` takes a block that will be run once the path is attempted. This block **must return an explicit boolean** 
(ie. `true` or `false`) to avoid any accidental truthy values creating unwanted access.

**Example**
```ruby
rules do
    can_sometimes('/login') # Anyone can access this path
end
```

#### :any and :all special parameters
Passing `can` or `can_sometimes`:
 * `:any` to the first parameter will match any HTTP method. 
 * `:all` to the second parameter will match any path. 

**Examples**
```ruby
# this allows get on all paths
can(:get, :all)

# this allows any method type to run on the /login path
can(:any, '/login')
```

###Bounce Customization
The default bounce action is to `halt 401`. Call `bounce_with` with a block that takes the sinatra application to change that behaviour. 

**Example**
```ruby
bounce_with do |application|
  application.redirect '/login'
end
```
