(

	local movespeed=0.1

	rollout joystick_rollout "Close this window to exit keyboard mode" width:300 height:1
	 (
		 timer theTicker interval:15 active:true
		 dotNetControl dnControl "System.Windows.Forms.Control"
		 local dnKeyboard = DotNetClass "System.Windows.Forms.Keys"
		 Local KeyPressed

		 on theTicker tick do (
			dnControl.focus() --sets focus
		 )

		 on dnControl KeyDown senderArg keyPressEventArgs do
		 (
			KeyPressed = keyPressEventArgs.keyCode
			keyPressEventArgs.SuppressKeyPress = true
			--print (KeyPressed)
			if KeyPressed==dnKeyboard.a then(
				print "a"
				$.pos.y+=movespeed
			)
			if KeyPressed==dnKeyboard.w then(
				print "w"
				$.pos.x+=movespeed
			)
			if KeyPressed==dnKeyboard.s then(
				print "s"
				$.pos.x-=movespeed
			)
			if KeyPressed==dnKeyboard.d then(
				print "d"
				$.pos.y-=movespeed
			)
			if KeyPressed==dnKeyboard.e then(
				print "e"
				$.pos.z+=movespeed
			) 
			if KeyPressed==dnKeyboard.c then(
				print "c"
				$.pos.z-=movespeed
			) 
			if KeyPressed==dnKeyboard.Space then(
				print "Space"
				$.pos=[0,0,0]
			)
			if KeyPressed==dnKeyboard.Tab then(
				print "Tab"
			)
		 )

		 on dnKeys KeyUp senderArg keyPressEventArgs do
		 (
			KeyPressed = undefined
		 )
	 )
	 createDialog joystick_rollout
	 
	 
 
 )