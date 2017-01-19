require "kemal"

module StpeteCrystal
  get "/hello" do |context|
    "Hello, web!"
  end
  Kemal.run

end
