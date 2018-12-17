  (
  --Get the base name without any digits:
  fn removeTrailingNumber theFilename =
  (
  	local theNumbers = #("0","1","2","3","4","5","6","7","8","9")
  	for i = theFilename.count to 1 by -1 do
  		if findItem theNumbers theFilename[i] == 0 do 
  			return (substring theFilename 1 i)
  	""		
  )
  
  --Get digits only from the file name:
  fn collectTrailingNumber theFilename =
  (
  	local theNumbers = #("0","1","2","3","4","5","6","7","8","9")
  	local theString = ""
  	for i = theFilename.count to 1 by -1 do
  		if findItem theNumbers theFilename[i] == 0 then
  			return theString
  		else
  			theString = theFilename[i] + theString
  	theString 		
  )
  
  --Get zeros string (for the format 0001,0123 etc.)
  --If you want just 01,02, you can change this or use your code:
  fn getZeros theNumber =
  (
  	theCount = (theNumber as string).count
  	if theCount > 3 then "" else substring "0000" 1 (4-theCount) 
  )
  
  --get the max path and name without the trailing number.
  --if the scene is untitled, make sure you fix the "" to "Untitled"
  theMaxName = maxFileName
  if theMaxName == "" do theMaxName = "Untitled"
  thePath = maxFilePath
  theName = removeTrailingNumber (getFileNameFile theMaxName)
  
  --get all files matching this pattern:
  allFiles = getFiles (thePath + theName + "*.max")
  
  --collect all numbers from all collected files 
  allNumbers = sort (for f in allFiles collect execute (collectTrailingNumber (getFileNameFile f)))
  
  --figure out what the highest number is
  if allNumbers.count > 0 then
  (
  	lastNumber = allNumbers[allNumbers.count]
  	if classof lastNumber != Integer do lastNumber = 0
  )	
  else
  	lastNumber = 0	
  
  --increment the last number and build the new file name
  nextNumber = lastNumber + 1
  newFilename = thePath + theName +getZeros nextNumber + nextNumber as string + ".max"
  
  --then do something with it, like saving the scene...
  
  )--end script