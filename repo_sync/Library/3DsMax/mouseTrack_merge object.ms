try(destroyDialog mergePlace)catch()

 fn PlaceObj msg ir obj faceNum shift ctrl alt =
  (   
	  if ir == undefined then
			myStr = mouse.pos
	  else
			myStr =  ir.pos
      case msg of
      (
          #mousePoint:
					(
						Object1.pos = myStr 
					)
          #mouseAbort: 
					(
						destroyDialog mergePlace
						exit
					)
      )
      #continue 
  )

global Object1
global terr
rollout mergePlace "Merge"
(
		button OpnFile "Open Merge File" 
		pickbutton chooseit  "Pick Object to be Placed On"
		button place "Place" width:130 height:40
		button Abt " ( , \")"
		
		on Abt pressed do
		(		
			rollout abut "About"
			(			
				label a1 "Written By Akram(Akira)"
				hyperLink blog "akira-techart.blogspot.com" address:"http://akira-techart.blogspot.com/"
			)		
			createDialog abut
		)
	
	on OpnFile pressed do
	(
		fl = getOpenFileName caption: "Merge File" types:"3ds Max (*.max)|*.max"
		if fl != undefined then 
		(
			objs = getMAXFileObjectNames fl
			if objs.count > 1 then
				mergeMaxFile fl #prompt #select
			else
				mergeMaxFile fl #select
			Object1 = selection
			OpnFile.text = filenameFromPath fl
		)
	)
	
	on chooseit picked sel do
	(
		if sel != undefined do
		(
			terr = sel
			chooseit.text = terr.name
		)
	)
	
	on place pressed do
	(
		mouseTrack on:terr snap:#3D trackCallback:PlaceObj 
	)
)

createDialog mergePlace