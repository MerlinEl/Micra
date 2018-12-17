--function gives time-of-day in milliseconds.
start = timeStamp()
process_mesh() -- do some big job
end = timeStamp()
format "Processing took % seconds\n" ((end - start) / 1000.0)





--do this when a file is opened
fn TTOpenFile = (
	TTPropNums()
	if trackingNum != 0 then (
		dateOpenArr = filterString localTime " "
		fileproperties.addProperty #custom "Pause Total" 0
		fileProperties.addProperty #custom "Time Open" ((timeStamp())/1000)
		fileProperties.addProperty #custom "Date Open" dateOpenArr[1] #date
		timeTotal = fileProperties.getPropertyValue #custom totalTimeNum
		dateOpenPrev = fileProperties.getPropertyValue #custom dateOpenNum
		pushPrompt ("TT ON, Last opened: " + dateOpenPrev + " ,Total time: " + TTGetTime timeTotal)
		if TTRollout != undefined then (
			if TTRollout.open == true then (
				TTRollout.trackFile.state = on
				TTRollout.trackFile.caption = "Stop tracking this file"
				)
			)
		)
		
		
		
		
	--turn seconds into hours, minutes, and seconds
fn TTGetTime a = (
	hours = a / 3600 as integer
	mins = ((a - (3600 * hours)) / 60) as integer
	seconds = (a - (3600 * hours) - (60 * mins)) as integer
	result = (hours as string) + "h:" + (mins as string) + "m:" + (seconds as string) + "s"
	return result
	)
