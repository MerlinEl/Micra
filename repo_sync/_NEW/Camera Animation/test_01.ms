


myindex = rendViewIndex
if (myindex !=0) do (
	if viewport.numViews == 1 and myindex != 1 then (
		max tool maximize
		--messagebox "A"
		oldview = viewport.activeViewport
		viewport.activeViewport = myindex
		max tool maximize
		--messagebox "B"
	 )
	else ( viewport.activeViewport = myindex )
	render vfb:on
	if viewport.numViews == 1 then (
		--messagebox "C"
		max tool maximize
		viewport.activeViewport = oldview
		--messagebox "D"
		max tool maximize
	 )
)


https://bitbucket.org/jcdeblok/freetools/src/aff0543e79658d7df77475317779c67fa114587e/ProSequencer/?at=master
ProSequencer.ms
Camera_Sequencer_v0.01.ms