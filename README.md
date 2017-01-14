# stpete_crystal

These are the notes and walk-through for the crystal talk I'm giving 
(or have already given and I'm too lazy to update this repo).  The goal is
to walk through the installation of crystal, init a new app, and write an
interactive chat system for the local network.  This document describes
what you need to do if you want to build the application on your own.  The 
code for the app is also here.

## Installation

#### Crystal

First, you need to install [crystal](https://crystal-lang.org/docs/installation/).  Easy enough,
unless you're running Windows.  Sorry no, no crystal for Windows.  You can confirm that it's
installed correctly, by running `crystal -v` in a terminal.  Right now, I'm
running `Crystal 0.20.3 [b1416e2] (2016-12-23)`.

I use Ubunutu (and this applies to all Debian distros), so I simply add the crystal repository to
my system:

```bash
curl https://dist.crystal-lang.org/apt/setup.sh | sudo bash
sudo apt-get update
sudo apt-get install crystal
```
Installation is that simple.


## The stppete_crystal app
#### Initialize the app
My personal preference is to have a ~/crystal folder where all my projects live, so that's
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

```ruby
require "./stpete_crystal/*"

module StpeteCrystal
  # TODO Put your code here
  puts "Hello, world"
end
```

Ok, drumroll plase.  From the `stpete_crystal` folder run your app (__do not forget the .cr
exteions__)

```bash
crystal src/stpete_crystal.cr
```

And lo and behold, look what happens!

```bash
Hello, world.
```

Modern technology never ceases to amaze me.  But let's just show a couple more things.  First,
we have to personalize `hello world`.  I think it's mandatory once you've invoked `hello world`.

So we change our line of code to something very familiar to rubyists.  A string interpolation:

```ruby
puts "Hello, #{ARGV[0]? || "world"}!"
```

From the terminal again:
```bash
crystal src/stpete_crystal.cr         # Hello, world!
crystal src/stpete_crystal.cr Jason   # Hello, Jason!
```

Ok, great.  It works.  I'm bored, can we do something useful?  Why yes, yes we can.

#### Add Shards

Crystal has a similar concept to ruby `gems`, installable libraries that you include in your app.
Instead of `gems`, they are `shards` in crystal.  We'll be using 
[kemal](http:://kemalcr.com), a "Lighting fast, super simple web framework written in Crystal"

kemal is **not** Ruby on Rails.  It's not a giant MVC framework.  It's a simpler web routing
library from which larger MVC frameworks can be (and are being) built.  It's similar to Rails'
routes, but at a lower level.

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

```ruby
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

So far, so good.


## Contributors

- [Jason Landry](https://github.com/jasonl99) Jason Landry - creator, maintainer
