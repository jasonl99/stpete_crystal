require "kemal"

module StpeteCrystal
  get "/hello" do |context|
    "Hello, web!"
  end

  get "/hello/:name" do |context|
    name = context.params.url["name"]
    "Hello, #{name.capitalize}!"
  end

  Kemal.run

end
