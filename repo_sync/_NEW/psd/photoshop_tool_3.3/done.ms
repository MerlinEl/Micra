(
	local	inst=true
	local 	s="script NOT installed."
	local	i="missing!"
	local	m="not defined!"

	try 
	(
		t=openbitmap ((getdir #ui)+"icons\JNpshop_24i.bmp")
		i="installed."
		close t
	)
	catch 	inst=false
	try
	(
		fileIn ((getdir #ui)+"macroscripts\open_bitmapin_photoshop_v3.2.mcr")
		m="defined."
	)
	catch 	inst=false
	if inst==true then s="To create an icon or install on quad menu:\n\ncustomize|customise user interface|category : JN Scripts"
	msg=s+"\n\nicons\t\t:\t"+i+"\nmacros\t\t:\t"+m+"\n\n\xa9 2004, 2009 Josh Newman www.joshuanewman.net"
	messagebox msg title:"Photoshop tool." beep:true
)