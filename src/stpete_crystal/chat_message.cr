module StpeteCrystal
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
end
