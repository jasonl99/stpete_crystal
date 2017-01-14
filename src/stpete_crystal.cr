require "./stpete_crystal/*"
require "kemal"

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
