require "./stpete_crystal/*"
require "kemal"
require "kemal-session"
require "kilt/slang"

module StpeteCrystal

  class_property visits = 0
  @@chat_room = ChatRoom.new("St Pete Crystal", samples: 5)
  class_property chat_room

  SOCKETS = [] of HTTP::WebSocket
  class ChatRoom
    class_property next_id  = 0
    property name = "Chat Room"
    @message_id = 0
    @messages = [] of ChatMessage
    MAX_MESSAGES = 5

    def status
      puts "Size: #{@messages.size}"
    end

    def initialize(@name, samples = 0)
      (1..samples).each do |num|
       add_message ChatMessage.new(
          user: %w(Jason Bob Paul Steve Mike Laurie Courtney Allison Jane).sample,
          message: ["Hey, how's it going", "Just got in town", "musta been disconnected"].sample,
          time: Time.now - (num*30).seconds
        )
      end
    end

    def add_message( message : ChatMessage)
      message.id = ( self.class.next_id += 1)
      @messages << message
      puts "ChatMessage added: #{message.inspect}"
      send_message message
      prune if @messages.size > MAX_MESSAGES
    end

    # send a message to all sockets
    def send_message( message : ChatMessage )
      puts "Sending message"
      send = {"newMessage" => message.display }.to_json
      puts "message.class: #{send.class}"
      SOCKETS.each &.send(send)
    end 

    def get_messages( max  = 10 )
      # we assume messages were added in order
      @messages
    end

    def display_messages
      get_messages.map(&.display).join("\n")
    end

    def display_form
      render "./src/views/chat_form.slang"
    end

    def display
      render "./src/views/room.slang"
    end

    def prune
      @messages = @messages[0..MAX_MESSAGES-1]
    end

  end

  struct ChatMessage
    property id      : Int32?
    property user    : String
    property time    : Time
    property message : String

    def initialize(@user, message, @time = Time.now)
      @message = message[0..99] # No rants allowed.
    end

    def display
      render "./src/views/message.slang"
    end

  end


  Session.config do |config|
    config.timeout = 2.minutes
    config.cookie_name = "session_id"
    config.secret = "some_secret"
    config.gc_interval = 2.minutes
  end

  ws "/socket" do |socket|
    SOCKETS << socket
    socket.on_close do
      SOCKETS.delete socket
    end
    socket.on_message do |msg|
      # msg = msg.to_json
      msg = JSON.parse msg

      if msg["chatMessage"]?
          puts "msg received: #{msg}, msg_class: #{msg.class}"
          puts "msg[chatMessage] : #{msg["chatMessage"]}"
          chat_message = ChatMessage.new(user: "socket", message: msg["chatMessage"].to_s)
          chat_room.add_message(chat_message)
      end
    end
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
    render "./src/page.slang"
  end


  Kemal.run

end
