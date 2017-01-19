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
