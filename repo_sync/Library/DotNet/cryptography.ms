--Ok, I've found it. I was using unicode enconding and when 
--I switched to ascii encoding it matched your md5 example right away.

function getTextHash HashMethod SourceText =
	(
		case tolower(HashMethod) of
		(
			"sha1" : hMethod = dotNetObject "System.Security.Cryptography.SHA1CryptoServiceProv  ider"
			default : hMethod = dotNetObject "System.Security.Cryptography.MD5CryptoServiceProvi  der"
		)
		ue =  dotNetObject "System.Text.ASCIIEncoding"
		bytesToHash = ue.GetBytes SourceText
		
		hash = hMethod.ComputeHash bytesToHash
		buff = dotnetObject "System.Text.StringBuilder"
		SysString = dotNetClass "System.String"
		for hashbyte in hash do
		(
			buff.Append (SysString.Format "{0:X2}" hashByte)
		)	
		buff.ToString()
	)

        oText = "hello@this@is.a.test"
	md5Text=getTextHash "MD5" oText
	sha1Text=getTextHash "SHA1" oText

        print ("MD5 text checksum: " + md5Text)
	print ("SHA1 text checksum: " + sha1Text)
	
	
	/*
	Result:

"MD5 text checksum: F236709EFC76DD20F3524C80B2C7E949"
"SHA1 text checksum: E271441A814597499784CBA0EBA7F00005545E18"
	*/
