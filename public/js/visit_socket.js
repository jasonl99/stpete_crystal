window.onload = function() {
  var ws = new WebSocket("ws://" + location.host + "/socket");
  // Append each message
  ws.onmessage = function(msg) { 
    console.log(msg);
    payload = JSON.parse(msg.data);

    if (payload.hasOwnProperty('newMessage')) {
      console.log("found new message");
      document.getElementById("message-holder").insertAdjacentHTML("beforeend",payload.newMessage);
    }
    
  };

  document.getElementById('chat-send').onsubmit = function(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    console.log(evt);
    msg = document.getElementById("new-msg");
    send = JSON.stringify({chatMessage: msg.value});
    console.log("sending",send)
    ws.send(send);
    document.getElementById("new-msg").value = ""
    console.log("Form submitted", evt)
    return false;
  }

  window.onbeforeunload = function() {
    websocket.onclose = function () {}; // disable onclose handler first
    websocket.close()
  };
};

