At the chat_room to the socket

```crystal
ws "/socket" do |socket|
  SOCKETS << ClientSocket.new socket, self.chat_room 
end
```

```javascript
  # We need little bit of code to bootstrap our websocket connection so we can
  # tie it to a session.  This merely creates javascript that looks like this in
  # the visitor's page:
  # var {"sessionID" => "this-is-my-session-id"}
  def self.create_javascript( user_session : Session)
     "var app_vars = " +  {"sessionID" => user_session.id}.to_json + ";"
  end
```

We need a chat room

```crystal
  class ChatRoom
    class_property next_id  = 0    # the next id of a newly-added message
    property name = "Chat Room"    # an arbitrary name
    @messages = [] of ChatMessage  # The indivual messsages that make up this chatroom, on the server
    MAX_MESSAGES = 20              # the maximum array size of @messages
    #...more code follows
  end
```

which are full of ChatMessages

```crystal

  class ChatMessage
    MAX_SIZE         = 100
    property id      : Int32?
    property user    : String
    property time    : Time
    property message : String

    def initialize(@user, message, @time = Time.now)
      @message = message[0..MAX_SIZE-1] # No rants allowed.
    end

    #...more code
  end
```
