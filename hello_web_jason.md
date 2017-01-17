# Hello, Jason! (from the web)

Obviously, we need to be able to personal our output.  It'll be done right within the
url, but it could also of course be done with forms.  For simplicity's sake, we'll read
the name from the url.

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

So now you go to `http://localhost:3000/hello` and you get `Hello, world!`. 
Go to `http://localhost:3000/hello/jason` and you get `Hello, Jason!`  Awesomeness!

Once thing that's amazing about the crystal compiler -- did you even
notice that it's statically-typed?  Static typing *can* good thing: it offers lots of 
benefits, but often makes coding more difficult as you have to specify types everwhere.
Crystal automates much of the typing, so it becomes almost invisible as you're coding./
More on that later.
