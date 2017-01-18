var StPeteCrystal = {}
window.onload = function() {
  StPeteCrystal["ws"] = new WebSocket("ws://" + location.host + "/socket");
  // Append each message
  StPeteCrystal["ws"].onmessage = function(msg) { 
    console.log(msg);
    payload = JSON.parse(msg.data);

    if (payload.hasOwnProperty('total-visits')) {
      messageHolder = document.getElementById("total-visits");
      console.log(document.getElementById("total-visits"));
      messageHolder.innerHTML = payload["total-visits"];
    }

    if (payload.hasOwnProperty('newMessage')) {
      console.log("found new message");
      messageHolder = document.getElementById("message-holder")
      messageHolder.insertAdjacentHTML("beforeend",payload.newMessage);
      messageHolder.scrollTop = messageHolder.scrollHeight
    }
    
  };

  document.getElementById('chat-send').onsubmit = function(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    msg = document.getElementById("new-msg");
    send = JSON.stringify({chatMessage: msg.value});
    StPeteCrystal["ws"].send(send);
    document.getElementById("new-msg").value = ""
    // console.log("sending",send)
    // console.log("Form submitted", evt)
    return false;
  }

  window.onbeforeunload = function() {
    StPeteCrystal["ws"].onclose = function () {alert("no close!")}; // disable onclose handler first
    // StPeteCrystal["ws"].close()
  };
};

