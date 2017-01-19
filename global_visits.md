# Global Visitors

The idea of incrementing a counter every time a new visitor comes to your site has been around
since the dawn of time, and, frankly, a bit silly.

But it offers a pretty simple way to show dynamic data.  So we'll build in a visitor counter
into our app and show it on the hello page.  Then we'll make it update automagically.

However, some business to attend to.  We're going to add a rendering engine so we can
start including some HTML easily into our system.  Kemal has a built in engine which uses 
Kilt (like Tilt), and has a template language called slang (like slim).  So we'll use them.

First, add a shard to the shard.yml file, under kemal-session:

```yml
  slang:
    github: jeromegn/slang
```

Run `shards install`

Then modify the src/stpete_crystal.cr file and require slang (slang is a plugin for kilt)

```crystal
require "kilt/slang"
```

We're going to produce a very simple web page `./src/views/page.slang`, and if you are familiar with slim, this
will look very familiar:


```slim
head
body
  h1 = "Hello, #{name}!"
  div
    | You started your visit at
    span#session-started = session_started
    | and you've visited 
    span#session-visits = session_visits
  div
    | We've had 
    span#total-visits = total_visits 
    | total visits since the app started.
```

That becomes our web page when we `render "./src/views/page.slang"`

We don't have to make a lot of changes to our code.

```crystal

module StpeteCrystal
  class_property visits = 0
  #... all the other code
end
```

Like rails, we end up with a getter and setter (you can also use class_getter and class_setter).
`class_property` is actually a macro that inserts the following code:

```crystal
def self.visits
  @@self.visits
end

def self.visits=(val)
  @@self.visits=val
end
```

Like ruby, crystal uses `@` for instance variables and `@@` for class variables.

We make one more change to our `display_hello` method:

```crystal
  def self.display_hello( user_session : Session)
    StpeteCrystal.visits += 1
    if user_session.string?("name")
      name = user_session.string("name").capitalize
    else
      name = "web"
    end
    session_started = user_session.string("session_started")
    session_visits = user_session.int("visit_count")
    total_visits = StpeteCrystal.visits
    render "./src/views/page.slang"
  end

```

Every time we run `display_hello` we increment the counter.  We also create a total_visits variable
for use in `./src/views/page.slang`.

And that's it.  We now visit our page and it looks like this:

---
# Hello, web!

You started your visit at 2017-01-19 17:01:35 -0500 and you've visited 1
We've had 1 total visits since the app started.<Paste>

---

Now on to more magic.

