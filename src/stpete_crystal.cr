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

  Session.config do |config|
    config.timeout = 2.minutes
    config.cookie_name = "session_id"
    config.secret = "some_secret"
    config.gc_interval = 2.minutes
  end

  ws "/socket" do |socket|
    SOCKETS << ClientSocket.new(socket, self.chat_room)
  end

  get "/hello" do |context|
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
    SOCKETS.each {|socket| socket.send send }
  end

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
      user_session.string("session_started", Time.now.to_s("%I:%M:%S %p"))
    end
  end

  # tie all the information we have on the visitor together
  # into a string.
  def self.display_hello( user_session : Session)
    if user_session.string?("name")
      name = user_session.string("name").capitalize
    else
      name = "web"
    end
    session_started = user_session.string("session_started")
    session_visits = user_session.int("visit_count")
    total_visits = StpeteCrystal.visits + 1
    StpeteCrystal.visits += 1  # this is done separately; calling it within a render caused issues
    render "./src/views/page.slang"
  end


  Kemal.run

end
