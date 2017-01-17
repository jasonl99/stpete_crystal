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

