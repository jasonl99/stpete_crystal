# stpete_crystal

These are the notes and walk-through for the crystal talk I'm giving 
(or have already given and I'm too lazy to update this repo).  The goal is
to walk through the installation of crystal, init a new app, and write an
interactive chat system for the local network.  This document describes
what you need to do if you want to build the application on your own.  The 
code for the app is also here.

## Installation

#### Crystal

#### What is [Crystal](https://crystal-lang.org/docs/installation/) anyway?

Well, the crystal-lang.org describes it this way:
* Have a syntax similar to Ruby (but compatibility with it is not a goal)
* Statically type-checked but without having to specify the type of variables or method arguments.
* Be able to call C code by writing bindings to it in Crystal.
* Have compile-time evaluation and generation of code, to avoid boilerplate code.
* Compile to efficient native code.

It has the best of both worlds -- the native speed of C with the joy of programming that ruby provides.

#### Installation

Installing crystal is easy enough,
unless you're running Windows.  Sorry, no crystal for Windows.  You can confirm that it's
installed correctly, by running `crystal -v` in a terminal.  Right now, I'm
running `Crystal 0.20.3 [b1416e2] (2016-12-23)`.

I use Ubunutu (and this applies to all Debian-based distributions), so I simply add the crystal repository to
my system:

```bash
curl https://dist.crystal-lang.org/apt/setup.sh | sudo bash
sudo apt-get update
sudo apt-get install crystal
```
Installation is that simple.


## The stpete_crystal app
#### Initialize the app
My personal preference is to have a `~/crystal` folder where all my projects live, so that's
where it will exist throughout this demo.


```bash
cd ~
mkdir crystal
cd crystal
crystal init app stpete_crystal
```

The app gets initialized by creating directories for code, libraries, and specs.  It also creates
an new git repository, convienently adding a `.gitignore` for files you shouldn't have under
version control.

#### Hello, world.
Seriously, do we really have to do `Hello, world` every time we learn how to write a program?

Well, I'd feel like I were leaving something out if I didn't.  So were' going to add one line
of code to a file that crystal created.

In the `./src/` directory, you'll find `stpete_crystal.cr`.  Add the line right where the code
tells you to (seriously, the generator added `# Put your code here`, how cool is that?)

```crystal
require "./stpete_crystal/*"

module StpeteCrystal
  # TODO Put your code here
  puts "Hello, world!"
end
```

Ok, drumroll plase.  From the `stpete_crystal` folder run your app (__do not forget the .cr
exteions__)

```bash
crystal src/stpete_crystal.cr
```

And lo and behold, look what happens!

```bash
Hello, world!
```

Modern technology never ceases to amaze me.  But let's just show a couple more things.  First,
we have to personalize `hello world`.  I think it's mandatory once you've invoked it.

So we change our line of code to something very familiar to rubyists.  String interpolation:

```crystal
puts "Hello, #{ARGV[0]? || "world"}!"
```

From the terminal:

```bash
crystal src/stpete_crystal.cr         # Hello, world!
crystal src/stpete_crystal.cr Jason   # Hello, Jason!
```

Ok, great.  It works.  I'm bored, can we do something useful?  Why yes, yes we can.

#### Add Shards.  Add what??

Crystal has a similar concept to ruby `gems`, installable libraries that you include easily in your app.
Instead of `gems`, they're called `shards` in crystal.  We'll be using 
[kemal](http:://kemalcr.com), a "lighting fast, super simple web framework written in Crystal"

kemal is **not** Ruby on Rails, not is it designed to be.  It's not a giant MVC framework.  It's a simpler web routing
library from which larger MVC frameworks can be (and are being) built.  It's similar to Rails'
routes, but at a lower level, and with some cool functionality like websockets.

So let's add kemal to our app.  To install shards, we edit the `shard.yml` file at the 
root of our app that was created by `crystal init app`.  Before we add our changes, 
it looks like this:

```yml
name: stpete_crystal
version: 0.1.0

authors:
  - Jason Landry <jasonl99@gmail.com>

targets:
  stpete_crystal:
    main: src/stpete_crystal.cr

crystal: 0.20.3

license: MIT
```

There are currently no shards in our file, so we'll have to add a `dependencies` section,
adding it under the targets: section.  The whole file should now look like this:

```yml
name: stpete_crystal
version: 0.1.0

authors:
  - Jason Landry <jasonl99@gmail.com>

targets:
  stpete_crystal:
    main: src/stpete_crystal.cr

dependencies:
  kemal:
    github: kemalcr/kemal
    branch: master

crystal: 0.20.3

license: MIT

```

As you've probably guessed, to install them, run `shards install`.  It'll grab the shards plus
install any dependencies.  I hate to say, but it's time to do version 3 of `hello world`, this
type as a web server.

#### Hello, web.

We now have a web framework installed.  We need to respond to requests.  Kemal has
[restful web services](http://kemalcr.com/docs/rest/) to make this easy.  We'll
just respond to a request to "hello":

We go back to `/src/stpete_crystal.cr`, and change it up a little:

```crystal
require "./stpete_crystal/*"
require "kemal"

module StpeteCrystal
  # TODO Put your code here
  get "/hello" do |context|
    "Hello, web!"
  end
  Kemal.run

end
```
Notice that we've also `require "kemal"` on the second line to use the shard we installed.

Start the app again `crystal src/stpete_crystal.cr`. You'll notice that, like Puma or Rainbow
for Ruby, the app is now serving http on port 3000.  So you go your browser and take a look
at http:://localhost:3000/hello and see what you get.

And for fun, let's personalize it, too.  

```ruby
module StpeteCrystal
  # TODO Put your code here
  get "/hello" do |context|
    "Hello, web!"
  end

  get "/hello/:name" do |context|
    name = context.params.url["name"]
    "Hello, #{name.capitalize}!"
  end
  Kemal.run

end
```

So now you go to http://localhost/hello and you get `Hello, world!`. 
Go to http://localhost/hello/jason and you get `Hello, Jason!`  Awesomeness!

Once thing that's amazing about the crystal compiler -- did you even
notice that it's statically-typed?  Static typing *can* good thing: it offers lots of 
benefits, but often comes with difficult rigidity.  Crystal makes this much easier.  
More on that later.

### Sessions

Sessions are essential for a web server.  Kemal has a session manager shard which 
we'll to the `shard.yml` file directly under the kemal shard:

```yml
dependencies:
	kemal:
		github: kemalcr/kemal
		branch: master
	kemal-session:
		github: kemalcr/kemal-session
		branch: master
```

run `shards install` 

We'll configure sessions in the `crystal src/stpete_crystal.cr` again:

```crystal
require "./stpete_crystal/*"
require "kemal"

module StpeteCrystal

  Session.config do |config|
    config.cookie_name = "session_id"
    config.secret = "sunshine"
    config.gc_interval = 2.minutes
  end

  get "/hello" do |context|
    "Hello, web!"
  end

  get "/hello/:name" do |context|
    name = context.params.url["name"]
    "Hello, #{name.capitalize}!"
  end

  Kemal.run

end
```

To give a quick illustration how sessions work, we'll create a new session the first time a visitor stops by keeps track of the time of the first visit and the number of pages loaded.

Load up `crystal src/stpete_crystal.cr` in your editor again, and update it:

```crystal
require "./stpete_crystal/*"
require "kemal"
require "kemal-session"

module StpeteCrystal

  Session.config do |config|
    config.cookie_name = "session_id"
    config.secret = "some_secret"
    config.gc_interval = 2.minutes # 2 minutes
  end

  get "/hello" do |context|
    update_session(context.session)
  end

  get "/hello/:name" do |context|
    update_session(user_session: context.session, 
                   visitor_name: context.params.url["name"])
  end

  # updates the current visitor's session, including the name.
  # This exploits one of crystal's features that's not
  # available in ruby: method overloads.
  def self.update_session( user_session : Session, visitor_name : String)
    user_session.string("name", visitor_name)
    update_session(user_session)
  end

  def self.update_session( user_session : Session)
    # update the visit count
    visit_count = (user_session.int?("visit_count") || 0 ) + 1
    user_session.int("visit_count", visit_count)

    # create the start time if it's not already there
    unless user_session.string?("session_started")
      user_session.string("session_started", Time.now.to_s) 
    end
    display_hello( user_session)
  end

  # tie all the information we have on the visitor together
  # into a string.
  def self.display_hello( user_session : Session)
    if user_session.string?("name")
      user_name = user_session.string("name").capitalize
    else
      user_name = "web"
    end
    "Hello #{user_name}! Your visit started 
     #{user_session.string("session_started")} 
     and you've loaded #{user_session.int("visit_count")} pages."
  end

  Kemal.run

end
```


## Contributors

- [Jason Landry](https://github.com/jasonl99) Jason Landry - creator, maintainer
