require "./stpete_crystal/*"    # require all files in this directory
require "kemal"                 # dependency in shard.yml 
require "kemal-session"         # dependency in shard.yml 

# The base namespace of our demo.  Any class or properties defined
# wiithin the module remain safe from other libraries, shards, etc.
module StpeteCrystal

  # modules are like classes, but can't be instantiated.  But they
  # can have class properties and class methods.  Here we define
  # total visits (across all users) and a chat room (the only one in the app)
  class_property visits = 0
  class_property chat_room = ChatRoom.new("St Pete Crystal", samples: 5)

  # we keep track of each websocket connection in a ClientSocket instance,
  # and keep them all stored in an array.
  SOCKETS = [] of ClientSocket

  # kemal-session exposes a top-level class to manage sessions.  It
  # does require some minor configuration.
  Session.config do |config|
    config.timeout = 2.minutes
    config.cookie_name = "session_id"
    config.secret = "some_secret"
    config.gc_interval = 2.minutes
  end

  # kemal's web framework supports all REST verbs (get post put patch delete etc)
  # with simple route matching - the first route that matches "wins" and that code
  # runs.  In that code, we're passed a context instance - an object that contains
  # the original request, the response, and a session.

  # respond to the /hello url and update the current session
  # with the values we need to keep track of for this visit.
  get "/hello" do |context|
    update_session(context.session)
    display_hello( context.session)
  end

  # respond to the /hello url plus a name.  For example,
  # /hello/jason.  In this case, we also pass the visitor
  # name to update_session.
  get "/hello/:name" do |context|
    update_session(user_session: context.session, 
                   visitor_name: context.params.url["name"])
    display_hello( context.session)
  end

  # an incoming socket connection at "/socket" - not this could be
  # any url you'd like.  However, sockets do not contain nearly
  # the info that a typical http request does - there is no context.
  # In this case, every new socket connection gets added to the array
  # of sockets along with reference to the chat_room
  ws "/socket" do |socket|
    SOCKETS << ClientSocket.new socket, self.chat_room 
  end


  # Every time the StpeteCrystal's visit count goes up, we
  # let every socket know.  No, you really wouldn't do this
  # on an actual app, but it demonstrates the power of what can be
  # done.  Note that the visit count as sent as a JSON objet through
  # the single socket we have for each visitor.
  def self.visits=( visit_count : Int32 )
    @@visits = visit_count
    send = {"total-visits" => visit_count.to_s }.to_json
    SOCKETS.each {|socket| socket.send send }
  end

  # We do no name checking whatsoever for this demo, but we still want
  # some semblence of order.  So when a new visitor presents a name
  # via /hello/name, we test keep adding "_01", "_02" etc until
  # we end up with a unique name.  In a real app, were probably wouldn't
  # loop through all sockets every time, though this only occurs
  # when a new session is created, not for each visit.
  def self.unique_name(visitor_name : String)
    names = SOCKETS.select(&.session).map(&.name)
    visitor_name = "#{visitor_name}_01" if names.index(visitor_name) 
    while names.index(visitor_name) 
      visitor_name = visitor_name.succ   #succ is "successor"
    end
    visitor_name
  end

  # kemal-session automatically manages our session for us,
  # abstracting away the need to store cookies, and automatically
  # cryptographically signs each session to prevent tampering.  From
  # our perspective, we have a few methods:  
  # we can set and read strings, floats, integers, booleans.
  # We us an Int32 to store visitor counts, and a string to store 
  # the data and time that the visit started.
  def self.update_session( user_session : Session)
    # update the visit count
    visit_count = (user_session.int?("visit_count") || 0 ) + 1
    user_session.int("visit_count", visit_count)

    # create the start time if it's not already there
    unless user_session.string?("session_started")
      user_session.string("session_started", Time.now.to_s("%I:%M:%S %p"))
    end
  end

  # a nice feature of crystal - method overloading.  We can define another
  # version of #update_session that also has a visitor_name parameter.
  # In this case, we update the visitor name and then call the 
  # simpler version of udpate_session
  def self.update_session( user_session : Session, visitor_name : String)
    validated_name = unique_name visitor_name
    user_session.string("name", validated_name)
    update_session(user_session)
  end


  # We need little bit of code to bootstrap our websocket connection so we can
  # tie it to a session.  This merely creates javascript that looks like this in
  # the visitor's page:
  # var {"sessionID" => "this-is-my-session-id"}
  def self.create_javascript( user_session : Session)
     "var app_vars = " +  {"sessionID" => user_session.id}.to_json + ";"
  end

  # this actual creates the page.  It uses kemal's #render
  # to create the output from a view/template/whatever the kids are calling them these days.
  # in this case, we're using the slang template language, which is similar to slim.
  # The view is rendered in the current context, so the /views/page.slang"
  # has access to any variables within this method.  In keeping with the law
  # of demeter, we'll create local variables for the tempate to use.
  def self.display_hello( user_session : Session)
    if user_session.string?("name")
      name = user_session.string("name").capitalize
    else
      name = "web"
    end
    session_started = user_session.string("session_started")
    session_visits = user_session.int("visit_count")
    total_visits = StpeteCrystal.visits + 1
    session_id = user_session.id
    javascript = create_javascript( user_session)
    StpeteCrystal.visits += 1  # this is done separately; calling it within a render caused issues
    render "./src/views/page.slang"
  end


  # this starts the loop that reads web requests.  At this point, 
  # we just react to requests.
  Kemal.run

end
