module StpeteCrystal
  class ClientSocket
    property chat_room : ChatRoom
    property socket : HTTP::WebSocket
    property session : Session?

    def initialize(@socket : HTTP::WebSocket, @chat_room : ChatRoom, @session = nil)
      socket.on_close {self.on_close}
      socket.on_message {|msg| self.on_message(msg)}
    end

    def name
      if session && (name = session.as(Session).string?("name"))
        name
      else
        "Anonymous"
      end
    end

    def send(msg)
      # the client may have closed the socket, in which case we get rid of it.
      if socket.closed?
        puts "socket is closed"
      else
        puts "socket sending: #{msg}".colorize(:green).on(:light_gray)
        socket.send msg
      end
    end

    def on_close
      socket.close
      SOCKETS.delete self
    end

    def set_session(msg)
      puts "Setting session_id for socket: #{msg}".colorize(:magenta).on(:light_gray)
      return unless msg["sessionID"]?   # we don't if no session or its already set
      self.session = Session.get msg["sessionID"].to_s
      unless self.session
        puts "session is now " + self.session.as(Session).id
      end
    end

    def on_message(msg : String)
      puts "msg received: #{msg}".colorize(:red).on(:light_gray)
      msg = JSON.parse msg
      set_session(msg)
      puts "chatMessage? #{msg["chatMessage"]? ? true : false}"
      if msg["chatMessage"]?
          puts "creating chatmessage"
          chat_message = ChatMessage.new(user: self.name, message: msg["chatMessage"].to_s)
          chat_room.add_message(chat_message)
      else
        puts "No chatmessage created"
      end
    end

  end
end
