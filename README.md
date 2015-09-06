#Sinatra-Bouncer
Simple authorization permissions extension for [Sinatra](http://www.sinatrarb.com/). Require the gem, then declare which routes are permitted based on your own logic. 

**Gemfile**
```ruby
gem 'sinatra-bouncer'
```

**Terminal**
```sh
gem install sinatra-bouncer
```

##Quickstart
###Step 1: Require/Register Bouncer

After registration, Bouncer will reject any request that either:
* has no rule associated with it, or
* has no associated rule that returns `true`

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
Call `rules` with a block that uses `can` and `can_sometimes` to declare which paths are legalduring this request.  The rules block is run in the context of the request, which means you will have access to sinatra helpers, 
the `request` object, and `params`.

```ruby
require 'sinatra'
require 'sinatra/bouncer'

rules do
  # example: allow any GET request
  can(:get, :all)
  
  # example: logged in users can edit their account
  if(current_user)
    can(:post, '/user_edits_account')
  end
end

# ... route declarations as normal below
```

## API
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

```ruby
rules do
    can_sometimes('/login') # Anyone can access this path
end
```

#### :any and :all special parameters
Passing `can` or `can_sometimes`:
 * `:any` to the first parameter will match any HTTP method. 
 * `:all` to the second parameter will match any path. 

```ruby
# this allows get on all paths
can(:get, :all)

# this allows any method type to run on the /login path
can(:any, '/login')
```

### Custom Bounce Behaviour
The default bounce action is to `halt 403`. Call `bounce_with` with a block to specify your own behaviour. The block is also run in a sinatra request context, so you can use helpers here as well. 

```ruby
require 'sinatra'
require 'sinatra/bouncer'

bounce_with do 
  redirect '/login'
end

# bouncer rules, routes, etc...
```
