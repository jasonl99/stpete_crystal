window.onload = function() {
  var ws = new WebSocket("ws://" + location.host + "/global_visits");
  // Append each message
  ws.onmessage = function(msg) { 
    document.getElementById('total-visits').innerHTML = msg.data;
  };

  window.onbeforeunload = function() {
    websocket.onclose = function () {}; // disable onclose handler first
    websocket.close()
  };
};

