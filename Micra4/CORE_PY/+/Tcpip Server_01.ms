global theString=""
global theTcpListener, theSocket
Fn BackgroundTcpListenerDoWork theSender theEvent = (
	
	IPAddress = DotNetClass "System.Net.IPAddress"
	theIPAddress = IPAddress.Parse "127.0.0.1"
	theTcpListener = DotNetObject "System.Net.Sockets.TcpListener" theIPAddress 5688
	theTcpListener.Start()
	theSocket = theTcpListener.AcceptSocket()
	while theString!="exit" do (
		
		theByteStream = DotNetObject "System.Byte[]" 10000
		format "while bytes:%\n" theByteStream	
		theSocket.Receive theByteStream
		Encoding = DotnetClass "System.Text.Encoding"
		theString = trimright (Encoding.UTF8.GetString(theByteStream))
		format "while str:%\n" theString	
	)
	theTcpListener.Stop()
	theSocket.Close()
	tt.stop()
)
BackgroundWorker = DotNetObject "System.ComponentModel.BackgroundWorker"
DotNet.AddEventHandler BackgroundWorker "DoWork" BackgroundTcpListenerDoWork 
BackgroundWorker.WorkerSupportsCancellation = true
BackgroundWorker.RunWorkerAsync()
tt = dotnetobject "System.Windows.Forms.Timer"
tt.Interval = 1000
fn makeRollout s e = (
	format "tick str:%\n" theString
	--if theString!="" do (try(execute theString;theString="" )catch(print "Error Occured!") )
)
dotnet.addEventHandler tt "Tick" makeRollout
tt.Start()


/*
dotnet.removeEventHandler tt "Tick" makeRollout
theString = "exit"
theTcpListener.Stop()
theSocket.Close()

*/