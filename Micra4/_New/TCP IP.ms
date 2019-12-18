/*Credits
  MaxControl  proof  of concept 1.0  
  Jonathan de Blok - www.jdbgraphics.nl*/
  --Globals  
  Global BackgroundWorker	--declaration only
  ip_address 				= "localhost" 
  port						   = 8081
  node_id					="BB_Connection"	  -- ***insert unique ID here **** Why?
  socket					--Should not be global, just for testing
    
  fn logEvent ev = format "%: %\n" localtime ev					--simple function for logging events   
  
  fn recEvent data socket = logEvent data						--eventHandler for incomming data, data is a string, socket is source from which it came
    
  fn connectEvent socket = logEvent "new connection"	--eventHandler for incomming  new connections
    
  fn closeEvent sender socket = --eventHandler  for closing
  	(
  		logEvent("closing..")
  		socket.Close()
  		sender.CancelAsync()
  		sender.Dispose()
  	)
    
  fn SocketConnect ip_address port Retries:5 =			--connect to existing socket using IP:PORT
  	(
  		  socket = dotNetObject "System.Net.Sockets.Socket" ( dotnetclass "System.Net.Sockets.AddressFamily" ).InterNetwork ( dotnetclass "System.Net.Sockets.SocketType" ).Stream ( dotnetclass "System.Net.Sockets.ProtocolType" ).Tcp
  		logEvent ("Connecting to "+ip_address +":"+(port as string))
  		for i = 1 to Retries where socket.connected != true do
  			(
  				try (socket.connect ip_address port)
  				catch
  					(
  						logEvent ("failed, retrying " + (i as string) + "..")
  						sleep 2
  					)
  			)
  	  
  		logEvent ("Connected to "+ip_address +":"+(port as string))
    
  		socket
  	)
  
  fn SocketSend socket data =--Send a string to a socket
  	(	
  		try (	
  				ascii_encoder = dotNetObject "System.Text.ASCIIEncoding"
  				bytes = ascii_encoder.GetBytes ( data as string + "\r" ) --"PING" as string
  				socket.Send bytes
  				logEvent ("data send")
  			)
  		catch (
  				logEvent ("error sending data")
  			)
  	)
  	
  fn receiveData sender e =  -- connection manager
  	(
  		ip_address=e.Argument[1]
  		port=e.Argument[2]
  		commands=e.argument[3]
  		node_id=e.Argument[4]
  
  		recData--=""
  		socket--="";
  		Encoding = DotnetClass "System.Text.Encoding"
  
  		while recData!="EXIT" do
  			(
  				try (
  						theByteStream = DotNetObject "System.Byte[]" 4096
  						socket.Receive theByteStream  -- blocking until it receives something
  						logEvent "received data"
  						recData = Encoding.UTF8.GetString(theByteStream)
  						recEvent recData socket  -- call callback with received data as argument
  						for command in commands do
  							(
  								SocketSend socket command
  								theByteStream = DotNetObject "System.Byte[]" 4096
  								socket.Receive theByteStream  -- blocking until it receives something
  								logEvent "received data"
  								recData = Encoding.UTF8.GetString(theByteStream)
  								--execute ("cb="+callback_data)
  								recEvent recData socket  -- call callback with received data as argument
  							)
  					)
  				catch (--no socket yet or connection lost, try (re)connecting 
  
  						socket = dotNetObject "System.Net.Sockets.Socket" ( dotnetclass "System.Net.Sockets.AddressFamily" ).InterNetwork ( dotnetclass "System.Net.Sockets.SocketType" ).Stream ( dotnetclass "System.Net.Sockets.ProtocolType" ).Tcp
  						logEvent ("Connecting to "+ip_address +":"+(port as string))
  						while socket.connected != true do
  							(
  								try (socket.connect ip_address port)
  								catch (
  										logEvent ("Connecting...")
  										sleep 2
  									)
  							)
  
  						ascii_encoder = dotNetObject "System.Text.ASCIIEncoding"
  						bytes = ascii_encoder.GetBytes (  ("@manager:register:"+node_id) as string )
  						socket.Send bytes
  
  						logEvent("Connected to "+ip_address +":"+(port as string))
  						--execute ("cb="+callback_connect)
  						connectEvent socket
  						--cb socket
  					)
  			)
  
  		--execute ("cb="+callback_close)
  		closeEvent sender socket
  	)
    
  fn SocketConnectFullDuplex ip_address port Commands node_id =--Setup background worker with receiver function and user defined callback, callback is a string with the name of the function,not a pointer to the function itself
  	(
  		BackgroundWorker = DotNetObject "System.ComponentModel.BackgroundWorker"
  		DotNet.AddEventHandler BackgroundWorker "DoWork" receiveData  
  		BackgroundWorker.WorkerSupportsCancellation = true
  		BackgroundWorker.RunWorkerAsync #(ip_address, port, Commands, node_id)
  		BackgroundWorker
  	)
  	
  if node_id != "" then
  	(
  		SocketConnectFullDuplex ip_address port #("get srvlist") node_id	-- start listening in the background for data, recieved is send to callback function
  	) else print "set node_id to something unique! exiting.."
	
	
	/*
Fn BackgroundWorkerDoWork theSender theEvent = (
	
	while not theSender.CancellationPending do print (random [0,0,0] [100,100,100])
	BackgroundWorker = DotNetObject "System.ComponentModel.BackgroundWorker"
	DotNet.AddEventHandler BackgroundWorker "DoWork" BackgroundWorkerDoWork 
	BackgroundWorker.WorkerSupportsCancellation = true -- enabled can stop
	BackgroundWorker.RunWorkerAsync() -- start
	BackgroundWorker.CancelAsync() -- stop
)
	*/
	
	
	
	/*
	other 
	
IPAddress = DotNetClass "System.Net.IPAddress"
theIPAddress = IPAddress.Parse "127.0.0.1"
theTcpListener = DotNetObject "System.Net.Sockets.TcpListener" theIPAddress 8081
theTcpListener.Start()
theString=""
print "Socket Open!"
theSocket = theTcpListener.AcceptSocket()
theTcpListener.stop()
	
	
	
socket = dotNetObject "System.Net.Sockets.Socket" (dotnetclass "System.Net.Sockets.AddressFamily").InterNetwork (dotnetclass "System.Net.Sockets.SocketType").Stream (dotnetclass "System.Net.Sockets.ProtocolType").Tcp
socket.connect ip_address port
buf = DotNetObject "System.Byte[]" 1000
fn doFaceShiftSocket =
(	
	try
	(
		while socket.Connected == true do
		(
			socket.Receive buf
		)
	)
	catch
	(
		-- do nothing
	)
)
thread = dotNetObject "system.componentModel.backgroundWorker"
dotnet.addEventHandler thread "DoWork" doFaceShiftSocket
thread.WorkerSupportsCancellation = true
thread.runWorkerAsync()
for i=0 to (buf.length-1) do
		print (buf.GetValue i)
-- close socket
socket.close()
	*/