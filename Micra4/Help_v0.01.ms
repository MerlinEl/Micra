shellLaunch "http://www.cestaslunce.cz/sluzby/skripty"  ""
--shellLaunch "http://czh-fs-38/dokuwiki/doku.php?id=d_arms:art:documents:art_tips:micratut" ""

/*
if mcMicraHelpDialog != undefined do destroyDialog mcMicraHelpDialog
rollout mcMicraHelpDialog "" width:448 height:304
(
	--Locals:----------------------------------------
	local dMove = false, DmPos
	local msg = #("Kuk   O_o","Este tu nic neni tak co tu zevlujes ?   :-D","Ale? notaaak   ^.^","hehe (.)(.)","a Let'!!! ^[._.]^[._.]^ a nezlob :-) Az to bude tak to bude... ")
	button btn1 "" pos:[124,184] width:12 height:12
	button btn2 "" pos:[156,160] width:12 height:12
	button btn3 "" pos:[108,204] width:12 height:12
	button btn4 "" pos:[200,136] width:12 height:12
	button btn5 "" pos:[172,160] width:12 height:12
	button btn6 "" pos:[140,184] width:12 height:12
	button btn7 "" pos:[184,136] width:12 height:12
	button btn8 "" pos:[92,204] width:12 height:12
	button btn9 "" pos:[212,112] width:12 height:12
	button btn10 "" pos:[228,112] width:12 height:12
	label lbl1 "Label" pos:[100,64] width:0 height:0
	label lbl2 "Comming Soon ...... ^-^" pos:[64,36] width:104 height:28
	groupBox grp1 "Micra III Help:" pos:[4,4] width:436 height:296
	groupBox grp2 "A" pos:[260,20] width:168 height:268
	button btn_close "*" pos:[428,4] width:12 height:12
	-->MoveMode
	on mcMicraHelpDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcMicraHelpDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcMicraHelpDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcMicraHelpDialog DmPos
	)
	--actions
	on btn_close pressed do destroyDialog mcMicraHelpDialog
	on btn9 pressed  do (messagebox msg[random 1 5])
	on btn7 pressed  do (messagebox msg[random 1 5])
	on btn5 pressed do (messagebox msg[random 1 5])
	on btn3 pressed do (messagebox msg[random 1 5])
	on btn1 pressed do (messagebox msg[random 1 5])
)
createDialog mcMicraHelpDialog style:#(#style_border)
*/