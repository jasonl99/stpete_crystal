body
  h1 = "Hello, #{name}!"
  div
    = "You started your visit at #{session_started} and you've visited #{session_visits}"
  div
    = "We've had #{total_visits} total visits since the app started."
