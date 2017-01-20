# WebSocket (git branch websockets)


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

## keep track of all the sockets

Web sockets are like live electrical wires.  Unlike http, once connected, a socket will stay
connected until it is closed.  We need to know which sockets to send data to.  

But before that, we want to abstract away the default class so we have some flexibility.  This
is our first class, so we'll put it in its own file `./src/stpete_crystal/client_socket.cr` 

```crystal
module StPeteCrystal
  class ClientSocket
    property socket : HTTP::WebSocket
  end
end
```

That gives as a class with a normal HTTP::WebSocket as a property.  We also start seeing
some of the benefit of strong typing:  socket can be nothing other than an HTTP::Socket, and
it can't even be nil (because we didn't say `socket : HTTP::WebSocket?`).

So if you try to compile this now, and somewhere in your code you have ClientSocket.new, you
will get a compiler error saying in so many words, that you're a dumbass, but more politely.

So how do we create a new one then?  We override the initialize method:

```crystal
def initialize(@socket)
end
```

Another interesting tidbit about crystal: It tries _really, really_ hard to figure out what
type everything is, and complains only when it can't figure it out.

We also see another cool feature.  By specifying the parameters as `@socket` as opposed to `socket`, 
we don't have to do `@socket = socket` in the initialize method.

So in this case, the compiler knows that we're setting the @socket property, and it knows that
it is a HTTP::WebSocket, so we don't event have to specificy.  That said, I think it's probably
beneficial to do it anyway; while you're reading through code, it makes it easier to see what 
it's doing.  The code above is exactly equivalent to

```crystal
def initialize(@socket : HTTP::WebSocket)
end
```

The next thing we need to do is respond to traffic to and from the socket.  The easy one sending:

```crystal
def send(msg)
  socket.send msg
end
```

This just passes through message from our instance to the underlying socket.  

Receiving is a little bit more complicated:  we need to know when something comes in 
through the socket.  So we update our initialize method a little.  While we're add it,
we'll add handling for the `#on_close` event.


```crystal
def initialize(@socket)
  socket.on_message {|msg| self.on_message(msg)}
  socket.on_close   {self.on_close}
end

def on_message(msg)
end

def on_close
end
```

So that's it.  We've effectively created our own version of a socket.  But now we
have to keep track of all of them.  We'll just keep track of them in a simple array for
now.

The logical place to do this is at the StpeteCrystal level, as a class variable.

So we modify src/stpete_crystal.cr
```crystal
module StpeteCrystal
  SOCKETS = [] of ClientSocket
  #...all the other code
end
```

Like ruby, crystal uses SHOUTCASE for globals.

Now that we have a place to store the sockets, each time one is created we need to add it,
and each time one is closed we need to remove it.  We know that we can't create one without
an already-instantiated socket, so where does this happen?  Simple.  In kemal's routing.

Similar to `#get`, kemal has `#ws` that we add a path to, and it conveniently passes the
socket.  So we just add this near our two `#get` blocks in src/stpetecrystal.cr

```crystal
ws "/socket" do |socket|
  SOCKETS << ClientSocket.new socket
end
```

Seriously, that's it.  Our sockets that come in at `/sockets` are automatically converted
to a ClientSocket and added to our array.

There's one more piece of socket handling:  removal of closed sockets in the SOCKETS array.

Go back to `web_socket.cr`, where we had added an `#on_close` method, and take care of it there:

```crystal
def on_close
  socket.close
  SOCKETS.delete self
end
```

___Boom.  Mic Drop.___

Haha.  Ok, still not doing anything useful.

We have to do a few new things.  For one, the browser needs to open a socket, we can't force it.
So that means we have to add javacript.  Kemal automatically serves from a `./pubic` directory,
so we'll put it in `'./public/js/visit_socket.js`

```javascript
var StPeteCrystal = {}
window.onload = function() {
  StPeteCrystal["ws"] = new WebSocket("ws://" + location.host + "/socket");
  StPeteCrystal["ws"].onmessage = function(socket) { 
    console.log(socket.data)

  window.onbeforeunload = function() {
    StPeteCrystal["ws"].onclose = function () {}; // disable onclose handler first
    StPeteCrystal["ws"].close()
  };
};
```

This does nothing useful yet, other than open the socket and print out anything it receives
to the console.  We're updating total visits.  Recall from the `./views/page.slang` we had
a `span#total-visits` (in slim/slang, this means `<span id="total-visits"></span>`

So we're going to read socket.data, assume it's JSON, and if there's a key of "total-vists"
update that element.

```javascript
StPeteCrystal["ws"].onmessage = function(socket) { 
    payload = JSON.parse(socket.data);

    if (payload.hasOwnProperty('total-visits')) {
      messageHolder = document.getElementById("total-visits");
      messageHolder.innerHTML = payload["total-visits"];
    }
```

That's it for the client side.  For the server, we need to update all the sockets that
we've kept track of in `SOCKETS` and send this data.

Simple.  We override the `visits=` method and send out the data

```crystal
  def self.visits=( visit_count : Int32 )
    @@visits = visit_count
    send = {"total-visits" => visit_count.to_s }.to_json
    SOCKETS.each {|socket| socket.send send }
  end
```

Now for the fun part.

Load up `http://localhost:3000/hello`.  Run apache-bench with 10,000 request, 20 at a time:

```bash
ab -n 10000 -c 20 localhost:3000/hello
```

Here's an animated gif that shows the live updates.  It's a bit slower due to `byzanz-record`, which
was used for recording.


<img src="https://raw.githubusercontent.com/jasonl99/stpete_crystal/master/updating.gif" alt="animated update" width="50%" height="50%">
