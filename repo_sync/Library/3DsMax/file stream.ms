--reading a max file as a binary file
(	
	thebytestream = fopen "C:\\Kuju-Work\unwrap.max" "rb"
	thesize = getfilesize "C:\\Kuju-Work\unwrap.max"
	i = 1
	while (i < thesize) do
	(

		thebyte = bit.intaschar (readbyte thebytestream)				
		format "%" ( thebyte)
		i+=1	

	)
	fclose thebytestream
)

------------------------------------
------------------------------------
------------------------------------

(
 	-- Reduced accuracy (+- 10 bytes) but exponential increase in speed!! 
 	-- average running time 50 - 400 milliseconds only .. (compared to 4 seconds earlier)!!
 	-- dropped an inner loop therefore slight chance of a miss.
 
 	st = timestamp()
 	
 		thefilename = "C:\\Kuju-Work\unwrap.max"
 		thefilesize = getfilesize thefilename	
 		bytestream = fopen thefilename "r"		
 		offset = 6
 		previousOffset = offset
 		realIndex = 0
 		thestring = ""
 		fseek bytestream -offset #seek_end
 		
 		while (offset <= (thefilesize-1)) do
 		(
 			flag = 0				
 			for index = 1 to (abs previousOffset) do
 			(			
 				thebyte = bit.intaschar (readbyte bytestream)
 				if thebyte!= "" do
 					thestring += thebyte
 				if (mod index 30 == 0) do
 				(				
 					if (findstring thestring "Version" != undefined) do
 					(
 						flag = 1				
 						realIndex = index - findstring thestring "Version" - 13 -- size of version * 2 coz of unicode
 						exit
 					)								
 					thestring = ""
 				)
 				if flag==1 do
 					exit
 				index+=1
 			)
 			if flag==1 do
 				exit		
 			offset = offset*10		
 			previousOffset = offset - previousOffset
 			offset = amin offset (thefilesize)			
 			fseek bytestream -offset #seek_end
 		)
 		
 		et = timestamp()
 		
 		if flag == 1 then
 			format "Location = % \n" (thefilesize-offset+realIndex)
 		else
 			format "increase the (mod index 30) value by 10 to (mod index 40) and so on...  and try again\n"
 	format "took % milliseconds" (et-st)
 	fclose  bytestream
 )
