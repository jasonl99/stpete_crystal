module StpeteCrystal
  class ChatRoom
    class_property next_id  = 0
    property name = "Chat Room"
    @message_id = 0  # the last assigned id for messages
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
      send_message message
      @messages << message
      prune if @messages.size > MAX_MESSAGES
    end

    # send a message to all sockets
    def send_message( message : ChatMessage )

      # puts "send message #{message}"
      send = {"newMessage" => message.display }.to_json
      # puts "sending message to #{SOCKETS.size} sockets"
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
end
