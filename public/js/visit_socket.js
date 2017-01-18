window.onload = function() {
  var ws = new WebSocket("ws://" + location.host + "/socket");
  // Append each message
  ws.onmessage = function(msg) { 
    document.getElementById('total-visits').innerHTML = msg.data;
  };

  document.getElementById('chat-send').onsubmit = function(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    console.log(evt);
    msg = document.getElementById("new-msg")
    ws.send(msg.value);
    document.getElementById("new-msg").value = ""
    console.log("Form submitted", evt)
    return false;
  }

  window.onbeforeunload = function() {
    websocket.onclose = function () {}; // disable onclose handler first
    websocket.close()
  };
};

