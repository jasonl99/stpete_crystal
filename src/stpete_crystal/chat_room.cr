module StpeteCrystal

  # A chatroom is a container for ChatMessages and some methods to handle them.
  class ChatRoom
    class_property next_id  = 0    # the next id of a newly-added message
    property name = "Chat Room"    # an arbitrary name
    @messages = [] of ChatMessage  # The indivual messsages that make up this chatroom, on the server
    MAX_MESSAGES = 20              # the maximum array size of @messages

    # initialize with a name, and an optional set of sample messages.
    def initialize(@name, samples = 0)
      (1..samples).each {|n| add_message sample_message}
    end

    # for demonstration purposes, it's nice to be able to have a few chat messages show up
    # when you load the page.
    def sample_message
      ChatMessage.new(
        user: %w(Jason Bob Paul Steve Mike Laurie Courtney Allison Jane).sample,
        message: ["How 'bout the Cubbies", "Hey, how's it going", "Just got in town", "Must have been disconnected"].sample,
        time: Time.now - [30,60,120,180,240,500].sample.seconds)
    end

    # add a message to the room and distribute it.
    def add_message( message : ChatMessage)
      message.id = ( self.class.next_id += 1)
      @messages << message
      send_message message
      prune
    end

    # send a message to all sockets
    def send_message( message : ChatMessage )
      send = {"newMessage" => message.display }.to_json
      SOCKETS.each &.send(send)
    end 

    # this gets an array of ChatMessage
    def get_messages( max  = MAX_MESSAGES )
      @messages.last(max)
    end

    # display each message using ChatMessage#display, and join them together with a newline
    def display_messages
      get_messages.map(&.display).join("\n")
    end

    # This is the form to create new messages as a user
    def display_form
      render "./src/views/chat_form.slang"
    end

    # display the entire room.
    def display
      render "./src/views/room.slang"
    end

    # We don't need five million messages, we just need MAX_MESSAGES.
    def prune
      @messages = @messages.last(MAX_MESSAGES) if @messages.size > MAX_MESSAGES
    end

  end
end
