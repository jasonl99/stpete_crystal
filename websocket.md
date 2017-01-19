# WebSocket

WebSockets are extremely simple full-duplex connections between client and server.  The are
both simpler and more powerful than AJAX.  A socket connection offers nothing useful on its
on, but it is reliable, works across proxy servers, and, I'm pretty sure, can get to Mars and
back.

You can read more [here](http://websocket.org/quantum.html)

In the same ways that crystal is faster than ruby, websockets are faster than AJAX
and other (let's just say it) hacks to simulate full-duplex communication.  Virtually
every browser that's newish supports websockets.

kemal, to our great advantage, has sockets built in, and they are pretty dang easy to use.

We're going to update our app so the global visit count is updated automatically, and
in realtime, as people visit.  We'll later use websockets for our chat app.


