--------------------------------------------------------------------------------
/* mcNet by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
	mcEvents
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	mcNet.isConnectionAvailable()
	mcNet.readFile "https://raw.githubusercontent.com/MerlinEl/Micra/master/Micra4_Release/update.xml"
*
*/
struct MICRA_NEW_STRUCTURE	(
	
	--variables
	debug=true,
	--WebClient,
	_target_file,
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn isConnectionAvailable = ( --Check ForInternet Connection
	
		try (
		
			local client = dotNetObject "System.Net.WebClient"
			client.OpenRead "http://clients3.google.com/generate_204"
			true
				
		) catch (false)
		
		/*
		Alternative >
		
		[DllImport("wininet.dll")]
			private extern static bool InternetGetConnectedState(out int connDescription, int ReservedValue);

		//check if a connection to the Internet can be established
			public static bool IsConnectionAvailable()
			{
				int Desc;
				return InternetGetConnectedState(out connDesc, 0);
			}
		
		public static bool WebRequestTest()
    {
        string url = "http://www.google.com";
        try
        {
            System.Net.WebRequest myRequest = System.Net.WebRequest.Create(url);
            System.Net.WebResponse myResponse = myRequest.GetResponse();
        }
        catch (System.Net.WebException)
        {
            return false;
        }
        return true;
    }
		
		private bool IsNetworkAvailable() {
		return System.Net.NetworkInformation.NetworkInterface.GetIsNetworkAvailable();
		}
		
		
		try { 
			Ping myPing = new Ping();
			String host = "google.com";
			byte[] buffer = new byte[32];
			int timeout = 1000;
			PingOptions pingOptions = new PingOptions();
			PingReply reply = myPing.Send(host, timeout, buffer, pingOptions);
			return (reply.Status == IPStatus.Success);
		}
		catch (Exception) {
			return false;
		}
		*/
	),
	fn readFile url = (
	
		if not isConnectionAvailable() do teturn undefined
		local spm = dotnetclass "System.Net.ServicePointManager"
		spm.SecurityProtocol = spm.SecurityProtocol.Tls12
		--try (
			--Create a request for the URL. 
			local request = (dotNetClass "System.Net.WebRequest").Create url
			request.Method = "GET"
			request.Timeout = 3000
			request.UserAgent = "3ds Max"
		   --If required by the server, set the credentials.  
			request.Credentials = (dotNetClass "System.Net.CredentialCache").DefaultCredentials
			--chache
			--System.Net.Cache.RequestCachePolicy
			local cl = (dotNetClass "System.Net.Cache.RequestCacheLevel").Default
			local po = dotnetObject "System.Net.Cache.RequestCachePolicy" cl.Default
			request.DefaultCachePolicy = po
			request.CachePolicy =  po
		--	request.DefaultCachePolicy  = (dotNetObject "System.Net.Cache.RequestCachePolicy").Default
		
			local response = request.GetResponse()
		   --Display the status.  
		   if debug do format "mcNet > readFile > StatusDescription:%\n " response.StatusDescription
		   --Get the stream containing content returned by the server. 
			local dataStream = response.GetResponseStream()
			--Open the stream using a StreamReader for easy access. 
			local encoding = (dotNetClass "System.Text.Encoding").GetEncoding "utf-8"
			local reader = dotNetObject "System.IO.StreamReader" dataStream encoding
			 --Read the content.
			local responseFromServer = reader.ReadToEnd()
			 --Display the content. 
			if debug do format "mcNet > readFile > responseFromServer:\n " responseFromServer
			--Close the reader and response.
			reader.Close()
			response.Close()
			dataStream.Close()
			return responseFromServer
			
		--) catch (
		
			format "Error: readFile > exception:\n" + getCurrentException()
		--)
		--undefined
	),
	fn downloadProgress s a = (mcPopUp.progeressbar a.ProgressPercentage msg:"Downoading..."),
	fn downloadCompleted s a = ( -- s(dotNetObject:System.Net.WebClient) a(dotNetObject:System.ComponentModel.AsyncCompletedEventArgs) #cancelled, #error, #UserState, #empty
	
		mcPopUp.progeressbar 100 msg:"Downoad Finished:" close:true
		dotNet.removeEventHandler s "DownloadProgressChanged" mcNet.downloadProgress
		dotNet.removeEventHandler s "DownloadFileCompleted" mcNet.downloadCompleted
		/*dotNet.removeEventHandler mcNet.WebClient "DownloadProgressChanged" mcNet.downloadProgress
		dotNet.removeEventHandler mcNet.WebClient "DownloadFileCompleted" mcNet.downloadCompleted*/
		if a.Error != undefined then (
		
			format "mcNet > downloadCompleted > Error:%\n" (a.Error.toString())
			mcEvents.dispatchEvent "FileWasDownloaded" data:""
			
		) else (
			mcEvents.dispatchEvent "FileWasDownloaded" data:mcNet._target_file
		)
	),
	/**
	*@Usage > Download file from url with progress bar
	*@Example
		fn fileDownloaded file = (
		
			format "MICRA_EVENTS > fileDownloaded > file:%\n"  data
		)
		mcEvents.registerEvent "FileWasDownloaded" fileDownloaded
		user_dir   = (pathConfig.removePathLeaf Micra.UserDir) + "\\"
		server_dir = "https://github.com/MerlinEl/Micra/raw/master/Micra4_Release/"
		mcNet.downloadFile (server_dir+"Micra4_v4.36.zip") (user_dir+"download_test.zip")
		>> MICRA_EVENTS > fileDownloaded > data:D:\ReneBaca\3DsMax\Micra\Micra4\User\download_test.zip
	*/
	fn downloadFile source_url target_file = (
		
		_target_file = undefined
		if not isConnectionAvailable() do (
		
			mcEvents.dispatchEvent "FileWasDownloaded" data:""
			return false
		)
		if doesFileExist target_file do deleteFile target_file --delete old file before download
		_target_file = target_file ---keep target file path
		--download new file
		local ServicePointManager = dotNetClass "System.Net.ServicePointManager"
		local SecurityProtocolType = dotNetClass "System.Net.SecurityProtocolType"
		ServicePointManager.Expect100Continue = true --using System.Net
		ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 --Use SecurityProtocolType.Ssl3 if needed for compatibility reasons
		
		if debug do format "mcNet > downloadFile > Downloading.... \n\tfrom:[ % ]\n\tto:[ % ]\n" source_url target_file
		WebClient = dotNetObject "System.Net.WebClient"
		dotNet.addEventHandler WebClient "DownloadProgressChanged" downloadProgress
		dotNet.addEventHandler WebClient "DownloadFileCompleted" downloadCompleted
		WebClient.DownloadFileAsync (dotNetObject "System.Uri" source_url) target_file
		WebClient.dispose()
	),
	fn uploadFile source_file target_url = (
	
		--code here

	)
	/*<end>*/
)	
 --create instance
Global mcNet = mcStructMan.instanceStructure MICRA_NEW_STRUCTURE "mcNet"


/*
	NI = dotnetclass "System.Net.NetworkInformation.NetworkInterface"
	NI.GetIsNetworkAvailable()
	ALL = NI.GetAllNetworkInterfaces()
	MACAddress = ALL[1].GetPhysicalAddress()
*/

/*
webrequest with POST 


   --Getting the mac address
        NI = dotnetclass "System.Net.NetworkInformation.NetworkInterface";
        NI.GetIsNetworkAvailable();
        ALL = NI.GetAllNetworkInterfaces();
        MACAddress = ALL[1].GetPhysicalAddress();
        print (MACAddress.toString());
    --Encoding the mac address so it is sendable
        A = (dotNetClass "System.Text.Encoding");
        PostData = "macaddress=" + MACAddress.toString();
        MData = A.ASCII.GetBytes (PostData);
    --Creating the Post request
        Req = (dotNetClass "System.Net.WebRequest").Create ("http://ip.mdfplan.com/");
        Req.Method = "Post";
        Req.ContentType = "application/x-www-form-urlencoded";
        Req.ContentLength = MData.count;
    --Writing the data in the request
        S = Req.GetRequestStream();
        S.write MData 0 MData.count;
        S.close();
    --Sending the request and recieving the response
        Res = Req.GetResponse();
        ResStr = Res.GetResponseStream();
    --Reading the respone
        objReader = dotnetobject "System.IO.StreamReader" ResStr;
        ResText = (objReader.ReadToEnd());
		
		
		
	using System;
	using System.Collections.Generic;
	using System.Text;
	using System.IO;	
	string URL = "FILE_URL_PATH";
	System.Net.WebRequest webRequest = System.Net.WebRequest.Create(URL);
	webRequest.Method = "POST";
	webRequest.ContentType = "application/x-www-form-urlencoded";
	Stream reqStream = webRequest.GetRequestStream();
	string postData = "username=YourUser&password=YourPassword";
	byte[] postArray = Encoding.ASCII.GetBytes(postData);
	reqStream.Write(postArray, 0, postArray.Length);
	reqStream.Close();
	StreamReader sr = new StreamReader(webRequest.GetResponse().GetResponseStream());
	string Result = sr.ReadToEnd();

	using (TextWriter tw = new StreamWriter("c:\\result.csv", true))
	(
	tw.Write(Result);
	)
}
*/