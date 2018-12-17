rollout xxx "Keyboard" width:162 height:300
(
	radioButtons rdo1Key "RadioButtons" pos:[32,44] width:29 height:62 labels:#("Micra Keys", "Yours Keys", "Max Default Keys") columns:1
	on rdo1Key changed stat do
    (
	   	case rdo1Key.state of
	   	(
			1: (print "Axis X")
			2: (print "Axis Y")
			3: (print "Axis Z")
	    )
	)	
)
createdialog xxx