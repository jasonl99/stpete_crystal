
module StpeteCrystal

  # an individual ChatMessage and for the most part pretty self-explanatory.
  class ChatMessage
    MAX_SIZE         = 100
    property id      : Int32?
    property user    : String
    property time    : Time
    property message : String

    def initialize(@user, message, @time = Time.now)
      @message = message[0..MAX_SIZE-1] # No rants allowed.
    end

    def display
      render "./src/views/message.slang"
    end

  end
end
