--Vsai
/*
Don't know how useful this is for anyone, but here's a little snippet to 
check the status of a service on a remote server. 
used as part of a little farm management utility that I'm updating to run 
with the 64bit stuff and experimenting with the net framework.
*/	
	
	
	fn checkService ServiceName server =
	(
		dotnet.loadassembly "System.ServiceProcess"
		sc = dotNetObject "System.ServiceProcess.ServiceController"
		if (server == "") do server = "." -- if no server is supplied, run the check on the local machine
		sc.Machinename = server
		try(scServices = sc.GetServices(server))catch(return "Timed Out")
		for scTemp in scServices do
		(
			if (scTemp.ServiceName as string == ServiceName) then
			(
				--print ( ServiceName + " - " + server + " - " +scTemp.Status.toString() )
				return scTemp.Status.ToString()
			) 
		)
		return "Service Not found"
	)