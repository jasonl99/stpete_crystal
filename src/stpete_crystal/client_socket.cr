module StpeteCrystal

  # ClientSocket is a composite object that joins together a persistent websocket
  # connection with a session and a chat_room, but it primarily deals with the
  # communication of the underlying websocket.  In effect, this gives the websocket
  # the context it needs to respond.
  class ClientSocket
    property chat_room : ChatRoom
    property socket : HTTP::WebSocket
    property session : Session?    # crystal syntax for specifying types includes ? for nullable.

    # a ClientSocket _must_ have an underlying socket and chatroom, though
    # it does not need a session.  
    # we also intercept socket #on_close and #on_message so we can
    # react.
    def initialize(@socket : HTTP::WebSocket, @chat_room : ChatRoom, @session = nil)
      socket.on_close {self.on_close}
      socket.on_message {|msg| self.on_message(msg)}
    end

    # we need a for some things.  get it from the session, or make it anonymous,
    def name
      if session && (name = session.as(Session).string?("name"))
        name
      else
        "Anonymous"
      end
    end

    # send a text string to the socket, if it's open,
    # if it's not, log something noticeable
    def send(msg)
      # the client may have closed the socket, in which case we get rid of it.
      socket.send msg
    end

    # when a socket is closed (this happens from the client closing it on thier end)
    # close it here, and remove it from our master list of sockets.
    def on_close
      socket.close
      SOCKETS.delete self
    end

    # this is the glue that ties a session to a socket.  When a socket is opened
    # on the client side, it immediately sends a JSON object
    # {"sessionID":"some_session_identifier"}
    # which is used to map into the session on the server.
    def set_session(msg)
      self.session = Session.get msg["sessionID"].to_s if msg["sessionID"]? 
    end

    # an incoming message was received on the underlying socket.
    # the only things we do are set a session and add to the chat room,
    # so ignore anything else.
    def on_message(msg : String)
      msg = JSON.parse msg
      set_session(msg) 
      if msg["chatMessage"]? && msg["chatMessage"].to_s.size > 0
        chat_message = ChatMessage.new(user: self.name, message: msg["chatMessage"].to_s[0..79])
        chat_room.add_message(chat_message)
      end
    end

  end
end
