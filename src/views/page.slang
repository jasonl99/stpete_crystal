head
  script type="text/javascript"
    == javascript
  script src="/js/visit_socket.js"
  link rel="stylesheet" href="/css/main.css"
body
  h1 = "Hello, #{name}!"
  div
    | You started your visit at
    span#session-started = session_started
    | and you've visited 
    span#session-visits = session_visits
  div
    | We've had 
    span#total-visits = total_visits 
    | total visits since the app started.
  == chat_room.display
