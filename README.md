# stpete_crystal

These are the notes and walk-through for the crystal talk I'm giving 
(or have already given and I'm too lazy to update this repo).  The goal is
to walk through the installation of crystal, init a new app, and write an
interactive app for the local network.  This document describes
what you need to do if you want to build the application on your own.  The 
code for the app is also here.

## Installation

#### Crystal

#### What is [Crystal](https://crystal-lang.org/docs/installation/) anyway?

Well, crystal-lang.org describes it this way:
* Have a syntax similar to Ruby (but compatibility with it is not a goal)
* Statically type-checked but without having to specify the type of variables or method arguments.
* Be able to call C code by writing bindings to it in Crystal.
* Have compile-time evaluation and generation of code, to avoid boilerplate code.
* Compile to efficient native code.

It has the best of both worlds -- the native speed of C with the joy of programming that 
ruby provides.

#### Installation

Installing crystal is easy enough, unless you're running Windows.  Sorry, 
no crystal for Windows.  You can confirm that it's installed correctly by running `crystal -v` 
in a terminal.  Right now, I'm running `Crystal 0.20.4 [d1f8c42] (2017-01-06)`.

I use Ubunutu (and this applies to all Debian-based distributions), so I simply add the 
crystal repository to my system:

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

### Demo Stages

The demo is organized into different sections as listed below, and each is described in the linked
markdown file.  There's a git branch in each section, too.  So you can see the code as it 
exists for that section by doing git checkout hello_word.

* [Hello, world!](hello_world.md) The compulsory `Hello, world!` app in crystal.
* [Hello, Jason!](hello_jason.md) The hello world app personalized
* [Shards](shards.md) Shards are crystal's equivalent to ruby gems.
* [Hello, web!](hello_web.md) A web version of hello word.
* [Hello, Jason v2](hello_web_jason.md) A personalized web version of hello world.
* [Sessions](web_session.md) Adding sessions to the web app
* [WebSocket](websocket.md) Web sockets FTW!

## Contributors

- [Jason Landry](https://github.com/jasonl99) Jason Landry - creator, maintainer
