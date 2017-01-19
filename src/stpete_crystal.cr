require "./stpete_crystal/*"
require "kemal"
require "kemal-session"
require "kilt/slang"
require "colorize"

module StpeteCrystal

  class_property visits = 0
  class_property chat_room = ChatRoom.new("St Pete Crystal", samples: 5)

  # @@chat_room = ChatRoom.new("St Pete Crystal", samples: 5)
  # class_property chat_room
  SOCKETS = [] of ClientSocket
  names = [] of String  # keep track of what names have been used

  Session.config do |config|
    config.timeout = 2.minutes
    config.cookie_name = "session_id"
    config.secret = "some_secret"
    config.gc_interval = 2.minutes
  end

  ws "/socket" do |socket|
    SOCKETS << ClientSocket.new socket, self.chat_room 
  end

  get "/hello" do |context|
    puts context.response.headers.inspect
    update_session(context.session)
    display_hello( context.session)
  end

  get "/hello/:name" do |context|
    update_session(user_session: context.session, 
                   visitor_name: context.params.url["name"])
    display_hello( context.session)
  end

  def self.visits=( visit_count : Int32 )
    @@visits = visit_count
    send = {"total-visits" => visit_count.to_s }.to_json
    puts "sockets total #{SOCKETS.size}".colorize(:yellow)
    SOCKETS.each {|socket| socket.send send }
  end

  def self.unique_name(visitor_name : String)
    names = SOCKETS.select(&.session).map(&.name)
    puts names
    visitor_name = "#{visitor_name}_01" if names.index(visitor_name) 
    puts "Index: #{names.index(name)}"
    while names.index(visitor_name) 
      puts "current visitor name: #{visitor_name}"
      visitor_name = visitor_name.succ
    end
    visitor_name
  end

  def self.update_session( user_session : Session, visitor_name : String)
    validated_name = unique_name visitor_name
    user_session.string("name", validated_name)
    update_session(user_session)
  end

  def self.update_session( user_session : Session)
    # update the visit count
    visit_count = (user_session.int?("visit_count") || 0 ) + 1
    user_session.int("visit_count", visit_count)

    # create the start time if it's not already there
    unless user_session.string?("session_started")
      user_session.string("session_started", Time.now.to_s("%I:%M:%S %p"))
    end
  end

  # tie all the information we have on the visitor together
  # into a string.
  def self.create_javascript( user_session : Session)
     "var app_vars = " +  {"sessionID" => user_session.id}.to_json + ";"
  end

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


  Kemal.run

end
