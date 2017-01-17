# Hello, web!

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
