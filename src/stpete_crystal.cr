require "./stpete_crystal/*"
require "kemal"
require "kemal-session"
require "kilt/slang"
require "colorize"

module StpeteCrystal

  class_property visits = 0
  @@chat_room = ChatRoom.new("St Pete Crystal", samples: 5)
  class_property chat_room
  SOCKETS = [] of HTTP::WebSocket

  class ClientSocket
    property chat_room : ChatRoom
    property socket    : HTTP::WebSocket

    def initalize(@socket, @chat_room)
      @socket.on_close {|closing| self.on_close}
      @socket.on_message {|message| self.on_message message}
    end

    def on_close
      SOCKETS.delete socket
    end

    def on_message(msg : String)
      msg = JSON.parse msg
      if msg["chatMessage"]?
          puts "msg received: #{msg}".colorize(:red).on(:light_gray)
          puts "msg[chatMessage] : #{msg["chatMessage"]}"
          chat_message = ChatMessage.new(user: "socket", message: msg["chatMessage"].to_s)
          chat_room.add_message(chat_message)
      end
    end

  end

  Session.config do |config|
    config.timeout = 2.minutes
    config.cookie_name = "session_id"
    config.secret = "some_secret"
    config.gc_interval = 2.minutes
  end

  ws "/socket" do |socket|
    SOCKETS << ClientSocket.new(@
    # socket.on_close do
    #   SOCKETS.delete socket
    # end
    # socket.on_message do |msg|
    #   # msg = msg.to_json
    #   msg = JSON.parse msg

    #   if msg["chatMessage"]?
    #       puts "msg received: #{msg}".colorize(:red).on(:light_gray)
    #       puts "msg[chatMessage] : #{msg["chatMessage"]}"
    #       chat_message = ChatMessage.new(user: "socket", message: msg["chatMessage"].to_s)
    #       chat_room.add_message(chat_message)
    #   end
    # end
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
    SOCKETS.each {|socket| socket.send visit_count.to_s}
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
    StpeteCrystal.visits += 1
    if user_session.string?("name")
      name = user_session.string("name").capitalize
    else
      name = "web"
    end
    session_started = user_session.string("session_started")
    session_visits = user_session.int("visit_count")
    total_visits = StpeteCrystal.visits
    render "./src/views/page.slang"
  end


  Kemal.run

end
