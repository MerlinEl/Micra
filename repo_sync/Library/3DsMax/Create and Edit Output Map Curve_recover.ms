try(destroydialog easyCCurve) catch()
rollout easyCCurve "Easy CCurve" width:208 height:215
(
	fn mouseWindowMove hwnd x y sx sy =
	(
		fn makeParam LoWord HiWord =
		(
			bit.or (bit.shift HiWord 16) (bit.and LoWord 0xFFFF)
		)
		WM_LBUTTONDOWN 	= 0x0201
		WM_LBUTTONUP 	= 0x0202
		WM_MOUSEMOVE	= 0x0200
		MK_LBUTTON	  = 0x0001
		
		p0 = makeParam x y
		p1 = makeParam (x+sx) (y+sy)
		
		uiaccessor.sendmessage hwnd WM_LBUTTONDOWN 0 p0 
		uiaccessor.sendmessage hwnd WM_MOUSEMOVE MK_LBUTTON p1 
		uiaccessor.sendmessage hwnd WM_LBUTTONUP 0 p1 
	)

	curveControl cc numcurves:1 width:200 height:200 pos:[4,4] \
		zoomvalues:[200,100] scrollvalues:[4,2] uiFlags:#() rcmFlags:#()
)
createdialog easyCCurve pos:[-1000,300] style:#() 

with redraw off
(
	d_hwnd = (windows.getChildHWND 0 easyCCurve.title)[1]
	c_hwnd = for w in (windows.getChildrenHWND d_hwnd) where w[4] == "DefCurveWindow" do exit with w[1]
	
	cc = easyCCurve.cc.curves[1]
	cc.color = orange
	cc.numpoints = 3
	pp = easyCCurve.cc.curves[1].points

	pp.selected = on
	pp[2].value = [1,0]
	pp[1].outtangent = [1,0]
	
	slidertime = 100
	undo off 
	(
		animate on easyCCurve.mouseWindowMove c_hwnd 0 100 0 10
		for k=1 to cc.numpoints do 
		(
--			format "%: % %\n" k cc[k] cc[k].controller
			deletekeys cc[k].controller #allkeys
		)
	)
	slidertime = 0
	
	pp.value = [0,0]
	pp.selected = off

	-- Edit Curve Points 
	pp[1].outtangent = [0,0]
	pp[3].value = [1,0]

	pp[2].value = [0.25,0.25]
	pp[2].outtangent = [0.2,0]
	pp[2].intangent = [-0.2,0]
	
	-- Animate Curve Point 2
	animate on at time 100 pp[2].value = [0.75,0.75]
	
	-- Make Output Map
	outputmap = output name:"ccOutput"
	medit.PutMtlToMtlEditor outputmap 1
	medit.SetActiveMtlSlot 1 on

	-- Init Mono_Color_Map 
	mateditor.open()
	c = windows.getchildhwnd (windows.getchildhwnd 0 ("Material Editor - " + outputmap.name))[1] "Enable Color Map"

	BM_SETCHECKED = 0x00F1
	UIAccessor.SendMessage c[1] BM_SETCHECKED 1 0
	UIAccessor.PressButton c[1]

	-- Replace Curve
	replaceinstances outputmap.output.Mono_Color_Map.curve_1 easyCCurve.cc.curves[1][1].parent
	medit.SetActiveMtlSlot 1 on
)
destroydialog easyCCurve
free easyCCurve