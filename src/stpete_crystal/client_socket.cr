module StpeteCrystal
  class ClientSocket
    property chat_room : ChatRoom
    property socket : HTTP::WebSocket

    def initialize(@socket : HTTP::WebSocket, @chat_room : ChatRoom)
      socket.on_close {self.on_close}
      socket.on_message {|msg| self.on_message(msg)}
    end

    def send(msg)
      puts "socket sending: #{msg}".colorize(:green).on(:light_gray)
      begin
        socket.send msg
      rescue msg
        puts "Rescued and closed #{msg.inspect}"
        socket.close
      end
    end

    def on_close
      SOCKETS.delete socket
    end

    def on_message(msg : String)
      msg = JSON.parse msg
      if msg["chatMessage"]?
          puts "msg received: #{msg}".colorize(:red).on(:light_gray)
          puts "msg[chatMessage] : #{msg["chatMessage"]}"
          chat_message = ChatMessage.new(user: "socket", message: msg["chatMessage"].to_s)
          chat_room.add_message(chat_message)
      end
    end

  end
end
