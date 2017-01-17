struct ChatMessage
  property user    : String
  property time    : Time
  property message : String

  def initialize(@user, @message, @time = Time.now)
  end
end

messages = [] of ChatMessage
messages << ChatMessage.new(user: "jason", message: "hello")
messages << ChatMessage.new(user: "jason", message: "older", time: 3.minutes.ago)
messages << ChatMessage.new(user: "jason", message: "much older", time: 3.hour.ago)


puts messages.inspect

puts messages.sort_by {|m| m.time}.map &.message
