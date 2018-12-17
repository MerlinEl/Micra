--------------------------------------------------------------------------------------------------------------------------------------
--	Script: AviPlayer
--	Version: 1.0
--	Recquires .Net support in MAXScript (at least version 9)
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
--	Author: Puech Yannick
--	Email: puechyannick@yahoo.fr
--  Website: http://ypuechweb.free.fr/
--	Date: 10/2007
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- Purpose : Uses DirectX Managed classes to load and play Avi videos in a .Net control/panel
--           Also a HScrollBar is used as time progression
--------------------------------------------------------------------------------------------------------------------------------------

MacroScript AviPlayer
	category:			"YPuech Tools"
	internalCategory:	"YPuech Tools"
	tooltip:			"Avi Player"
	ButtonText:			"Avi Player"
	silentErrors:		false
(
	------------------------------------------------------------------------------------------------------------------------------------------

	local uiAviPLayerRollout
	local aviFileName
	local aviVideo
	local aviTimer
	
	local nSilentVolume = -10000
	local nInitVolume = 80
	
	------------------------------------------------------------------------------------------------------------------------------------------
	
	fn convertSecondToTimeString timesSeconds =
	(
		-- Convert to string
		secondsString = timesSeconds as string
		-- Delete "0d" end part
		secondsString = substring secondsString 1 (secondsString.Count-2)
		-- Convert to integer
		second = secondsString as integer
		
		-- Get time components

		hour = second / 3600
		minute = second / 60 - hour * 60
		second = second - (hour * 3600 + minute * 60)
		
		-- Build strings

		hourString = hour as string
		if hourString.count == 1 then
		(
			hourString = "0" + hourString
		)
		
		minuteString = minute as string
		if minuteString.count == 1 then
		(
			minuteString = "0" + minuteString
		)
			
		secondString = second as string
		if secondString.count == 1 then
		(
			secondString = "0" + secondString
		)
		
		-- Set final time string
		timeString = hourString + ":" + minuteString + ":" + secondString
	)
	
	------------------------------------------------------------------------------------------------------------------------------------------
	
	rollout uiAviPLayerRollout "Avi Player" width:600 height:431
	(
		----------------------------------------------------------------------------------------------------------------------------------
		
		dotNetControl aviPanel "System.Windows.Forms.Panel" pos:[10,10] width:580 height:380
		button btnPickAvi "Pick Avi" pos:[10, 400] width:80 height:21
		checkbutton btnPlayAvi "Play" pos:[105, 400] width:50 height:21 checked:false
		button btnStopAvi "Stop" pos:[165, 400] width:50 height:21
		dotNetControl scrlAviPos "System.Windows.Forms.HScrollBar" pos:[233, 400] width:300 height:21
		spinner spnAviSound "" pos:[550,402] width:40 height:21 range:[0,100,nInitVolume] type:#integer
		
		----------------------------------------------------------------------------------------------------------------------------------
		
		fn updateAviUI =
		(
			if aviVideo != undefined then
			(
				CurrentAviPosition = aviVideo.CurrentPosition
				CurrentAviDuration = aviVideo.Duration
				
				-- Set HScrollBar value
				scrlAviPos.Value = CurrentAviPosition
				
				-- Set rollout title
				PositionString = convertSecondToTimeString CurrentAviPosition
				DurationString = convertSecondToTimeString CurrentAviDuration
				uiAviPLayerRollout.title = "AVI Player - Playing " + aviFileName + " - " + PositionString + " / " + DurationString
			)
		)
		
		----------------------------------------------------------------------------------------------------------------------------------
		
		on uiAviPLayerRollout open do
		(
			-- Init HScrollBar
			scrlAviPos.Minimum = 0
			scrlAviPos.SmallChange = 1
			scrlAviPos.LargeChange = 1
		)
		
		----------------------------------------------------------------------------------------------------------------------------------
		
		on uiAviPLayerRollout close do
		(
			-- Cleanup timer resources
			if aviTimer != undefined then
			(
				aviTimer.Stop()
				aviTimer.Dispose()
			)
			
			-- Cleanup video resources
			if aviVideo != undefined then
			(
				aviVideo.Stop()
				aviVideo.Dispose()
			)
			
			-- Cleanup managed data
			ManagedGC = dotNetClass "System.GC"
			ManagedGC.collect()
			
			-- Cleanup MAXScript heap
			gc light:true
		)
		
		----------------------------------------------------------------------------------------------------------------------------------
		
		on aviPanel paint senderArg paintEventArgs do
		(
			if  aviVideo == undefined then
			(
				graphics = paintEventArgs.Graphics
				
				Color = dotNetClass "System.Drawing.Color"
				graphics.Clear Color.Black
			)
		)
		
		----------------------------------------------------------------------------------------------------------------------------------
		
		on btnPickAvi pressed do
		(
			aviFile = getOpenFileName \
					  caption:"Open an Avi File:" \
				      types:"Avi Files (*.avi)|*.avi|All Files (*.*)|*.*|"
			
		    if aviFile != undefined then
		    (
			    -- Dispose of the old timer to clean up resources
				if aviTimer != undefined then
				(
					aviTimer.Stop()
					aviTimer.Dispose()
				)
				
				-- Create timer
			    aviTimer = dotNetObject "System.Windows.Forms.Timer"
			    dotNet.AddEventHandler aviTimer "tick" updateAviUI
				aviTimer.Interval = 1000
				aviTimer.Start()

				-- Set rollout title
				aviFileName = filenameFromPath aviFile
				uiAviPLayerRollout.title = "AVI Player - Playing " + aviFileName

				-- Remember the original dimensions of the panel
				PanelWidth = aviPanel.Width
				PanelHeight = aviPanel.Height

				-- Dispose of the old video to clean up resources
				if aviVideo != undefined then
				(
					aviVideo.Stop()
					aviVideo.Dispose()
				)
		
				-- Open the video
				try
				(
					aviVideo = dotNetObject "Microsoft.DirectX.AudioVideoPlayback.Video" aviFile
				)
				catch
				(
					messageBox  ("Error while loading " + aviFile + "!") title:"Avi Player"
				)

				-- Assign the WinForm control that will contain the video
				aviVideo.Owner = aviPanel

				-- Resize to fit in the panel
				aviPanel.Width = PanelWidth
				aviPanel.Height = PanelHeight

				-- Set HScrollBar Maximum
				scrlAviPos.Maximum = aviVideo.Duration
				
				-- Play Avi video
				aviVideo.Play()
				
				-- Avi is now played, the user can pause it
				btnPlayAvi.text = "Pause"
				
				-- Set audio volume if it exists
				if aviVideo.Audio != undefined then
				(
					aviVideo.Audio.Volume = nSilentVolume+(nInitVolume*100)
				)
				
				-- Force Avi panel redraw
				aviPanel.Invalidate()
		    )
		)
		
		----------------------------------------------------------------------------------------------------------------------------------
		
		on btnPlayAvi changed state do
		(
			if aviVideo != undefined then
			(
				if state then
				(
					aviVideo.Pause()
					btnPlayAvi.text = "Play"
				)
				else
				(
					aviVideo.Play()
					btnPlayAvi.text = "Pause"
				)
			)
		)
		
		----------------------------------------------------------------------------------------------------------------------------------
		
		on btnStopAvi pressed do
		(
			if aviVideo != undefined then
			(
				aviVideo.Stop()
			)
		)
		
		----------------------------------------------------------------------------------------------------------------------------------
		
		on spnAviSound changed value do
		(
			if aviVideo.Audio != undefined then
			(
				aviVideo.Audio.Volume = nSilentVolume+(value*100)
			)
		)
		
		----------------------------------------------------------------------------------------------------------------------------------
		
		on scrlAviPos scroll do
		(
			if aviVideo != undefined then
			(
				aviVideo.CurrentPosition = scrlAviPos.Value
			)
		)
	)
	
	------------------------------------------------------------------------------------------------------------------------------------------
	
	on execute do
	(
		try
		(
			dotnet.loadAssembly "Microsoft.DirectX.AudioVideoPlayback.dll"
		)
		catch
		(
			messageBox "Unable to find DirectX Managed Assemblies!" title:"Avi Player"
		)
		
		try(destroyDialog uiAviPLayerRollout)catch()
		createdialog uiAviPLayerRollout
	)
	
	------------------------------------------------------------------------------------------------------------------------------------------
)
