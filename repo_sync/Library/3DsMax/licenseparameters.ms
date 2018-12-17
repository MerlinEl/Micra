hid = hardwarelockid as string
pver = substring (maxops.productversion as string) 15 (maxops.productversion as string).count
ltype = (if maxops.isnetworklicense then "Network" else "Stand-alone")
lbhvr = substring (maxops.licensebehavior as string) 16 (maxops.licensebehavior as string).count
ldays = maxops.licensedaysleft
if ldays > 3653 then ldays = "Indefinite" else ldays = ldays as string

if licenseui != undefined do closerolloutfloater licenseui
licenseui = newrolloutfloater "License Parameters" 400 179
rollout roui ""
(
	edittext productversion_txt "Product Version: " text:pver
	edittext licensetype_txt "License Type: " text:ltype
	edittext licensebehavior "License Behavior: " text:lbhvr
	edittext licensedaysleft_txt "License Days Left: " text:ldays
	edittext hardwarelockid "License ID: " text:hid
)
addrollout roui licenseui	