#### Shards

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

