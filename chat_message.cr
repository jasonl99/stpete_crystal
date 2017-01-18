require "kemal"
require "kilt/slang"
class ChatRoom
  class_property next_id  = 0
  property name = "Chat Room"
  @message_id = 0
  @messages = [] of ChatMessage
  MAX_MESSAGES = 25 

  def status
    puts "Size: #{@messages.size}"
  end
  def initialize(@name)
  end

  def add_message( message : ChatMessage)
    message.id = ( self.class.next_id += 1)
    @messages << message
    prune if @messages.size > MAX_MESSAGES
  end

  def get_messages( max  = 10 )
    # we assume messages were added in order
    @messages
  end

  def display_messages
    get_messages.map(&.display).join("\n")
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

cr = ChatRoom.new "St Pete Ruby"
(0..90).each do |num|
  cr.add_message ChatMessage.new(
    user: %w(Jason Bob Paul Steve Mike Laurie Courtney Allison Jane).sample,
    message: ["Hey, how's it going", "Just got in town", "musta been disconnected"].sample,
    time: Time.now - (num*30).seconds
  )
end
puts cr.status
puts cr.display
