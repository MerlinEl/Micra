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
	WebClient,
	_target_file,
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Example
		mcNet.getCurrencyCourse "EMU"
		mcNet.getCurrencyCourse "Polsko"
		mcNet.getCurrencyCourse "Rusko"
	*/
	fn getCurrencyCourse country debug:false = (

		--vystavit požadavek na dnešní den
		local local_date = (dotNetClass ("System.DateTime")).Now
		local url = (dotnetClass "System.String").Format "http://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.txt?date={0:dd.MM.yyyy}" local_date
		local request = (dotNetClass "System.Net.HttpWebRequest").Create url
		--odeslat jej na server a získat odpověď
		local rs = request.GetResponse()
		--vytvořit StreamReader pro pohodlnou práci
		local dataStream = rs.GetResponseStream()
		local sr = dotNetObject "System.IO.StreamReader" dataStream
		--projít řádky
		local kurz = ""
		local mena = "" 
		while Not sr.EndOfStream do (

			local text_line = dotnetObject "System.String" (sr.ReadLine()) --"země|měna|množství|kód|kurz"
			--print (text_line.toString()) 
			--pokud jsme na řádku s dolarem, vytáhnout z něj kurz
			if text_line.StartsWith(country+"|") do (

				mena = (text_line.split "|" )[2]
				kurz = dotnetObject "System.String" ( text_line.Substring ((text_line.LastIndexOf "|") + 1) )
				kurz = kurz.replace "," "." --replace comma with dot
			)
		)	 
		--zavřít StreamReader
		sr.Close()
		--zavřít spojení
		rs.Close()
		--vypsat aktuální kurz
		if debug do format "Aktuální kurz: 1 % = %Kč\n" mena kurz
		execute kurz
	),
	fn isConnectionAvailable = ( --Check ForInternet Connection
	
		try (
		
			local client = dotNetObject "System.Net.WebClient"
			client.OpenRead "http://clients3.google.com/generate_204"
			true
				
		) catch (false)
	),	
	fn readFile url = (
		
		if not isConnectionAvailable() do teturn undefined
		local spm = dotnetclass "System.Net.ServicePointManager"
		spm.SecurityProtocol = spm.SecurityProtocol.Tls12
		try (
			
			--Create a policy that allows items in the cache  to be used if they have been cached one day or less.
			/*local time_span = (dotnetCLass "System.TimeSpan").FromDays 1
			local age_controll =  (dotnetCLass "System.Net.Cache.HttpCacheAgeControl").MaxAge
			local requestPolicy = dotnetObject "System.Net.Cache.HttpRequestCachePolicy" age_controll time_span*/
			--Create a request for the URL. 
			local request = (dotNetClass "System.Net.WebRequest").Create url
			
			
			--Turn off keep alive
			request.KeepAlive = false;
			--OutOfMemoryException when sending data
			request.AllowWriteStreamBuffering = false;

			request.Method = "GET"
			request.Timeout = 3000
			request.UserAgent = "3ds Max"
			request.Credentials = (dotNetClass "System.Net.CredentialCache").DefaultCredentials --If required by the server, set the credentials.  
			--disable chache store (Next reading will be actual not a CACHE!)
			local cache_level =  dotNetClass "System.Net.Cache.HttpRequestCacheLevel"
			local noCachePolicy = dotnetObject "System.Net.Cache.HttpRequestCachePolicy" cache_level.NoCacheNoStore
			request.DefaultCachePolicy = noCachePolicy
			request.CachePolicy = noCachePolicy -- Set the policy for this request only.
		   -- Get the response.  
			local response = request.GetResponse()
			--Determine whether the response was retrieved from the cache.  
           if debug do format "The response was retrieved from the cache :%\n." response.IsFromCache
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
			dataStream.Close()
			response.Close()
			return responseFromServer
			
		) catch (
		
			format "Error: readFile > exception:\n" + getCurrentException()
		)
		undefined
	),
	fn readFile_old url = (
		
			if not isConnectionAvailable() do teturn undefined
		local spm = dotnetclass "System.Net.ServicePointManager"
		spm.SecurityProtocol = spm.SecurityProtocol.Tls12
		try (
			--Create a request for the URL. 
			local request = (dotNetClass "System.Net.WebRequest").Create url
			request.Method = "GET"
			request.Timeout = 3000
			request.UserAgent = "3ds Max"
		   --If required by the server, set the credentials.  
			request.Credentials = (dotNetClass "System.Net.CredentialCache").DefaultCredentials
		   -- Get the response.  
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
			dataStream.Close()
			response.Close()
			return responseFromServer
			
		) catch (
		
			format "Error: readFile > exception:\n" + getCurrentException()
		)
		undefined
	),
	fn readFile_old2 url = (
	
		if not isConnectionAvailable() do teturn undefined
		local spm = dotnetclass "System.Net.ServicePointManager"
		spm.SecurityProtocol = spm.SecurityProtocol.Tls12
		try (
			--disable chache store (Next reading will be actual not a CACHE!)
			local http_request = (dotNetClass "System.Net.HttpWebRequest").Create url
			local cache_level =  dotNetClass "System.Net.Cache.HttpRequestCacheLevel"
			local policy = dotnetObject "System.Net.Cache.HttpRequestCachePolicy" cache_level.Default
			http_request.DefaultCachePolicy = policy
			--Create a request for the URL. 
			local request = (dotNetClass "System.Net.WebRequest").Create url
			request.Method = "GET"
			request.Timeout = 3000
			request.UserAgent = "3ds Max"
		   --If required by the server, set the credentials.  
			request.Credentials = (dotNetClass "System.Net.CredentialCache").DefaultCredentials
			--disable chache store (Next reading will be actual not a CACHE!)
			local noCachePolicy = dotnetObject "System.Net.Cache.HttpRequestCachePolicy" cache_level.NoCacheNoStore
			request.CachePolicy =  noCachePolicy
		   -- Get the response.  
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
			dataStream.Close()
			response.Close()
			return responseFromServer
			
		) catch (
		
			format "Error: readFile > exception:\n" + getCurrentException()
		)
		undefined
	),
	fn downloadProgress s a = (mcPopUp.progeressbar a.ProgressPercentage msg:"Downoading..."),
	fn downloadCompleted s a = ( -- s(dotNetObject:System.Net.WebClient) a(dotNetObject:System.ComponentModel.AsyncCompletedEventArgs) #cancelled, #error, #UserState, #empty
	
		mcPopUp.progeressbar 100 msg:"Downoad Finished:" close:true
		dotNet.removeEventHandler s "DownloadProgressChanged" mcNet.downloadProgress
		dotNet.removeEventHandler s "DownloadFileCompleted" mcNet.downloadCompleted
		WebClient.dispose()
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
	),
	fn uploadFile source_file target_url = (
	
		--TODO test mode
		/*local webRequest = (dotNetClass "System.Net.WebRequest").Create target_url
		webRequest.Method = "POST"
		webRequest.ContentType = "multipart/form-data"--"application/x-www-form-urlencoded"
		local reqStream = webRequest.GetRequestStream()
		local postData = "username="+user_name+"&password="+password
		local ste = (dotnetClass "System.Text.Encoding")
		local postArray = ste.ASCII.GetBytes postData
		reqStream.Write postArray 0 postArray.Length
		reqStream.Close()
		local sr = dotNetObject "System.IO.StreamReader" ((webRequest.GetResponse()).GetResponseStream())
		result = sr.ReadToEnd()
		local tw = dotnetObject "System.IO.StreamWriter" source_file true
		tw.Write Result*/
		
		
		/*
		FileStream fs = null;
WebRequest req = null;
Stream reqst = null;

fs = new FileStream(SourceFilePath, FileMode.Open, FileAccess.Read);
int totalLength = (((int)fs.Length) + 1);
byte[] buffer = new byte[totalLength];

fs.Read(buffer, 0, buffer.Length);

req = WebRequest.Create(GlobalHandler.g_strUploadUrl);
req.Method = "POST";

req.ContentType = "multipart/form-data";
WebHeaderCollection WH = new WebHeaderCollection();
WH.Add("FileName", MyFileName);

req.Headers = WH;

req.ContentLength = buffer.Length;

reqst = req.GetRequestStream(); //add data to request stream
Print("Geting Request Stream");
reqst.Write(buffer, 0, buffer.Length);// (buffer, 0, buffer.Length);
*/
	)
	/*<end>*/
)	
 --create instance
Global mcNet = mcStructMan.instanceStructure MICRA_NEW_STRUCTURE "mcNet"


/*
	fn webRequestTest = (

		local url = "http://www.google.com"
		try (

			local request = (dotNetClass "System.Net.WebRequest").Create url
			local response = request.GetResponse()

		) catch (

			return false
		)
		return true
	)


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


/*
	local policy = (dotNetClass "System.Net.Cache.HttpRequestCacheLevel").Default
	request.DefaultCachePolicy = policy
	local noCachePolicy = dotnetObject "System.Net.Cache.HttpRequestCachePolicy" policy.NoCacheNoStore
	request.CachePolicy =  noCachePolicy
*/
