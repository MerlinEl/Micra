select $mt_*
for o in selection do 
(
	for t=1 to o.tag_names.count do 
	(
		local tg = getNodeByName o.tag_names[t]
		tg.name =replace tg.name 1 2 "tg"
		o.tag_names[t] =replace o.tag_names[t] 1 2 "tg"
	)
)
for o in selection do o.name = replace o.name 1 2 "mt"