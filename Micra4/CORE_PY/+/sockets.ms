-- http://techarttiki.blogspot.com/2009/12/maxscript-dotnet-sockets-with-python.html


socket = \
   dotNetObject "System.Net.Sockets.Socket" ( dotnetclass "System.Net.Sockets.AddressFamily" ).InterNetwork \
 ( dotnetclass "System.Net.Sockets.SocketType" ).Stream \
 ( dotnetclass "System.Net.Sockets.ProtocolType" ).Tcp
socket.Connect ip_string port_int



-------------------------------------------
client
-------------------------------------------
mxs_socket.py

struct mxs_socket (
   ip_address = "127.0.0.1", -- "localhost" also valid
   port       = 2323,        -- default port
 
   -- <dotnet>connect <string>ip_string <int>port_int
   --
   -- Description:
   -- Takes IP address, port and connects to socket listener at that
   -- address
   fn connect ip_string port_int = (
      socket = dotNetObject "System.Net.Sockets.Socket" ( dotnetclass "System.Net.Sockets.AddressFamily" ).InterNetwork ( dotnetclass "System.Net.Sockets.SocketType" ).Stream ( dotnetclass "System.Net.Sockets.ProtocolType" ).Tcp
      socket.Connect ip_string port_int
 
      socket   -- return
   ),
 
   -- <int>send <string>data
   --
   -- Description:
   -- Converts a string (or any object that can be converted
   -- to a string) to dotnet ASCII-encoded byte sequence and
   -- sends it via socket. Uses ip_address and port defined
   -- in struct above, or set by client.
   -- Returns integer of how many bytes were sent.
   fn send data = (
      -- Convert string to bytes
      ascii_encoder = dotNetObject "System.Text.ASCIIEncoding"
      bytes = ascii_encoder.GetBytes ( data as string )
 
      -- Connect, send bytes, then close
      socket = connect ip_address port
      -- result is # of bytes sent
      result = socket.Send bytes
      socket.Close()
 
      result  -- return # of bytes sent
   )
)


-------------------------------------------
call client
-------------------------------------------
socket = mxs_socket port:5432
socket.send "Hello, World!"



-------------------------------------------
server
-------------------------------------------


def run( self ):
   self.running = True
 
   while ( self.running ):
      # Starting server...
      # Listen for connection.  We're in non-blocking mode so it can
      # check for the signal to shut down from the main thread.
      try:
         client_socket, clientaddr = self.socket.accept( )
         data_received = True
      except socket.error:
         data_received = False
 
      if ( data_received ):
         # Set new client socket to block.  Otherwise it will
         # inherit the non-blocking mode of the server socket.
         client_socket.setblocking( True )
 
         # Connection found, read its data then close
         data = client_socket.recv( self.buffer_size )
         client_socket.close( )
 
         # Create wx event and post it to our app window
         event = self.event_class( data = data )
         wx.PostEvent( self.window, event )
