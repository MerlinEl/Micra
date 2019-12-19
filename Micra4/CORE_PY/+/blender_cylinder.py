
 # Blender Cylinder Generator
 # Author: Satish Goda (satishgoda@gmail.com)
 # Date: June 22, 2005
 # License: None.
 # Tested using Blender 2.37. The text editor had a tabspacing of 2
 # Usage: Press ALT+P in the text window and play with the sliders
 
 import Blender
 from Blender import Text, Object, NMesh, Scene, Window, Draw, Registry
 from Blender.BGL import glColor3f, glRectf, glRasterPos2i
 from math import cos, sin, tan, fabs, radians
 
 #-----------------------------------------------------------------------
 
 # function pointers to module functions
 Keys = Registry.Keys
 GetKey = Registry.GetKey
 SetKey = Registry.SetKey
 Face = NMesh.Face
 Button = Draw.Button
 DrawText = Draw.Text
 NewText = Text.New
 GetText = Text.Get
 Slider = Draw.Slider
 Toggle = Draw.Toggle
 
 #-----------------------------------------------------------------------
 
 # dictionary of all widgets and some of their properties
 dwidget = {
 	'h': 		[None, 5.0, "The height of the cylinder."],
 	'ang':	[None, 0.0, "Taper angle. If angle = 0.0, its a cylinder."],
 	'seg': 	[None, 5, "Number of segments in the object"], 
 	'brad': [None, 5.0, "The base radius of the cylinder."],
 	'turn': [None, 360.0, "Sweep angle of the cylinder."],
 	'tface': [None, 1, "Chose if the cylinder has a top face"],
 	'bface': [None, 1, "Choose if the cylinder has a bottom face"],
 	'closed': [None, 1, "Choose if the solid is closed or not if sweep < 360 degrees.", "Warning%t|Since turn == 360, toggle does not affect."],
 	'newob': [None, 0, "Create a new object"],
 	'selob': [None, 0, "Modify the selected object."],
 	'copyfrom': [None, 0, "Apply settings from the selected object."],
 	'quit': [None, 0, "Quit this script"],	
 }
 
 datum = ['h', 'ang', 'seg', 'brad', 'turn', 'tface', 'bface', 'closed']
 
 newline, tab = '
', '	'
 skname = "BICG"
 selobname = None
 ob, me, sc, dBICG  = None, None, None, None
 
 #-----------------------------------------------------------------------
 
 def InitDataFile():
 	global dBICG
 	dBICG = GetKey(skname)
 	if not dBICG:
 		dBICG = d = {}
 		SetKey(skname, d)
 	
 #-----------------------------------------------------------------------
 	
 def DeselectAllObjects():
 	for object in Object.GetSelected(): object.select(0)
 
 #-----------------------------------------------------------------------
 
 def GenerateVertices(me, rad, isegs, h, turn):
 	fanglestep = turn /float(isegs)
 	fangle = 0.0
 	while fangle < turn:
 		x = rad * cos(radians(fangle))
 		y = rad * sin(radians(fangle))
 		vert = NMesh.Vert(x, y, h)
 		me.verts.append(vert)
 		fangle += fanglestep
 
 #-----------------------------------------------------------------------
 
 def AddFace(me, fil):	
 	vl = me.verts
 	facelist = [vl[index] for index in fil]
 	me.faces.append(Face(facelist))
 
 #-----------------------------------------------------------------------
 	
 def GenerateFaces(me, turn, tface, bface, closed):
 	vl = me.verts
 	length = len(me.verts)
 	offset = 2
 	segs = int((length-offset)/2)	
 
 	# get the index of the top and bottom vertices
 	if tface or bface:	tvi, bvi = length-2, length-1
 
 	ra = range(0, segs)
 	for index in ra:
 		if turn < 360.0 and closed:
 			if index == ra[0]:
 		    	vi1, vi2, vi3, vi4 = index, length-2, length-1, index+segs
 				AddFace(me, [vi1, vi2, vi3, vi4])
 			if index == ra[-1]:
 		    	vi1, vi2, vi3, vi4 = index, index+segs, length-1, length-2
 				AddFace(me, [vi1, vi2, vi3, vi4])
 		
 		if (turn == 360.0) or ((turn < 360.0) and (not closed) and (index != ra[-1])) or (closed and (index != ra[-1])):
 			vi1, vi4, vi2, vi3 = index, index+1, index+segs, index+segs+1
 			if vi4 == segs: vi4 = vi4 % segs
 			if vi3 == segs*2: vi3 = (vi3 % segs) + segs
 			AddFace(me, [vi1, vi2, vi3, vi4])
 			if tface:	AddFace(me, [tvi, vi1, vi4])
 			if bface:	AddFace(me, [bvi, vi2, vi3])
 			
 #-----------------------------------------------------------------------
 
 # Function to generate any isolated vertices
 def GenerateVertex(me, x, y, z):
 	vert = NMesh.Vert(x, y, z)
 	me.verts.append(vert)
 
 #-----------------------------------------------------------------------
 
 # clear vertex and face lists of the mesh from last update
 def ClearMeshGeometry(me):
 	del me.verts[:]
 	del me.faces[:]	
 
 #-----------------------------------------------------------------------
 
 # update the settings of the widgets
 def SetData(sdata, ui):
 	global datum
 	index=0
 	for ddata in datum:
 		ui[ddata][1] = sdata[index]
 		index += 1
 
 # retrieve settings from the user-interface elements
 def GetData(ui):
 	return [ ui[data][1] for data in datum]
 
 #-----------------------------------------------------------------------
 
 # Called whenever user-settings change 	
 # and at script start with default settings
 def UpdateMesh():
 	global ob, me, sc, dwidget
 		
 	# get input parameters to generate the cylinder
 	h, angle, isegs, baserad, turn, tface, bface, closed = GetData(dwidget)
 
 	toprad = baserad - (h * tan(radians(angle)))
 	# NOTE: to avoid getting weird shapes, uncomment the line below
 	toprad = fabs(toprad)
 	
 	ClearMeshGeometry(me)
 	
 	# generate the vertices of the top circle and base circle
 	GenerateVertices(me, toprad, isegs, h, turn)
 	GenerateVertices(me, baserad, isegs, 0.0, turn)
 
 	# make a vertex at top-center and bottom-center
 	GenerateVertex(me, 0.0, 0.0, h)
 	GenerateVertex(me, 0.0, 0.0, 0.0)
 
 	# Generate face list
 	GenerateFaces(me, turn, tface, bface, closed)
 	
 	# update the mesh
 	me.update()
 	DeselectAllObjects()
 	ob.select(1)
 	Blender.Redraw()
 
 #-----------------------------------------------------------------------
 
 def DrawWidgets():
 	global dwidget
 	dwidget['newob'][0]   = Button("New", 10009, 10, 10, 200/4, 20, dwidget['newob'][2])
 	dwidget['copyfrom'][0]   = Button("Copy", 10011, 200/4+10, 10, 200/4, 20, dwidget['copyfrom'][2])
 	dwidget['selob'][0]   = Button("Sel", 10010, 400/4+10, 10, 200/4, 20, dwidget['selob'][2])
 	dwidget['quit'][0]	= Button("Quit", 10008, 600/4+10, 10, 200/4, 20, dwidget['quit'][2])
 	dwidget['h'][0]     	  =  Slider("height : ", 10000, 10, 10+25, 200, 20, dwidget['h'][1], 2.0, 10.0, 1, dwidget['h'][2])
 	dwidget['ang'][0]	 = Slider("angle : ", 10001, 10, 10+25*2, 200, 20, dwidget['ang'][1], 0.0, 89.0, 1, dwidget['ang'][2])
 	dwidget['seg'][0] 	  = Slider("segments : ", 10002, 10, 10+25*3, 200, 20, dwidget['seg'][1], 3, 200, 1, dwidget['seg'][2])		
 	dwidget['brad'][0]	  = Slider("base radius : ", 10003, 10, 10+25*4, 200, 20, dwidget['brad'][1], 3.0, 15.0, 1, dwidget['brad'][2])
 	dwidget['turn'][0]	  = Slider("turn : ", 10004, 10, 10+25*5, 200, 20, dwidget['turn'][1], 5.0, 360.0, 1, dwidget['turn'][2])	
 	dwidget['tface'][0]   = Toggle("top", 10005, 10, 10+25*6, 200/3, 20, dwidget['tface'][1], dwidget['tface'][2])
 	dwidget['bface'][0]   = Toggle("bottom", 10006, 200/3 + 10, 10+25*6, 200/3, 20, dwidget['bface'][1], dwidget['bface'][2])
 	dwidget['closed'][0]  = Toggle("closed", 10007, 400/3 + 10, 10+25*6, 200/3, 20, dwidget['closed'][1], dwidget['closed'][2])	
 
 #-----------------------------------------------------------------------
 
 def DrawBanner():
 	x, y = 10.0, float(10+25*7)
 	w, h = 200.0, 50.0
 	glColor3f(0.3, 0.3, 0.3)
 	glRectf(x, y, x+w, y+h)
 	glColor3f(1.0, 1.0, 1.0)		
 	glRasterPos2i(int(x+5), int(y+5))
 	DrawText("by Satish 'iluvblender' Goda",'small')		
 	glRasterPos2i(int(x+5), int(y+20))
 	DrawText("Blender 2.37")
 	glRasterPos2i(int(x+5), int(y+35))
 	DrawText("Interactive Cylinder Generator")
 
 #-----------------------------------------------------------------------
 
 def ManageDisplay():
 	DrawWidgets()	
 	DrawBanner()
 
 #-----------------------------------------------------------------------
 
 # Save the name of the object and its data
 def DumpData():
 	global ob, dBICG, dwidget
 	if ob:
 		dBICG[ob.name] = GetData(dwidget)
 		SetKey(skname, dBICG)
 		
 #-----------------------------------------------------------------------
 
 def Terminate():
 	DumpData()
 	Draw.Exit()
 
 #-----------------------------------------------------------------------
 
 def ManageEvent(evt, val): 
 	if evt == Draw.QKEY: Terminate()
 
 #-----------------------------------------------------------------------
 
 def UpdateSlider(slider):
 	slider[1] = slider[0].val
 
 #-----------------------------------------------------------------------
 
 def UpdateToggle(toggle):
 	toggle[1] = toggle[0].val
 
 #-----------------------------------------------------------------------
 
 def NewObject(flag):
 	global ob, me, sc
 	if flag == 1: DumpData()
 	DeselectAllObjects()
 	sc = Scene.GetCurrent()
 	cursorpos = Window.GetCursorPos()
 	ob = Object.New('Mesh', 'Cyl_')
 	me = NMesh.New('MyCylMesh')
 	ob.setLocation(cursorpos)
 	ob.link(me)
 	sc.link(ob)
 
 #-----------------------------------------------------------------------
 	
 # Load the settings of the selected object into the GUI
 def LoadSettings(targetob):
 	notloaded = 0
 	try: 
 		data = dBICG[targetob]
 		SetData(data, dwidget)
 		return not notloaded
 	except KeyError:
 		Draw.PupMenu("ERROR: OOPS. This objects data does not exist in the registry.")	
 		return notloaded
 
 #-----------------------------------------------------------------------
 
 def CheckSelection():
 	selob = Object.GetSelected()
 	if not selob: 
 		Draw.PupMenu("Warning%t|Please make a selection.")
 	elif ob and selob[0].name == ob.name: 
 		Draw.PupMenu("Warning%t|Object already selected.")
 	else:
 		return selob[0]
 	
 	return None
 
 #-----------------------------------------------------------------------
 	
 def CopyFromObject():
 	sob = CheckSelection()
 	if sob: LoadSettings(sob.name)
 
 #-----------------------------------------------------------------------
 
 def SelectedObject():
 	global ob, me
 	sob = CheckSelection()
 	if sob:
 		DumpData()
 		if LoadSettings(sob.name):
 			ob, me = sob, sob.data		
 	
 #-----------------------------------------------------------------------
 
 def ManageWidgets(evt):
 	global dwidget, ob, me
 	if evt == 10000: UpdateSlider(dwidget['h'])
 	if evt == 10001: UpdateSlider(dwidget['ang'])
 	if evt == 10002: UpdateSlider(dwidget['seg'])
 	if evt == 10003: UpdateSlider(dwidget['brad'])
 	if evt == 10004: UpdateSlider(dwidget['turn'])	
 	if evt == 10005: UpdateToggle(dwidget['tface'])	
 	if evt == 10006: UpdateToggle(dwidget['bface'])
 	if evt == 10007:
 		if dwidget['turn'][1] == 360.0: Draw.PupMenu(dwidget['closed'][3])
 		else: UpdateToggle(dwidget['closed'])
 	if evt == 10008: Terminate()
 	if evt == 10009: NewObject(1)
 	if evt == 10010: SelectedObject()
 	if evt == 10011: CopyFromObject()	
 	if ob and me: UpdateMesh()
 
 #-----------------------------------------------------------------------
 
 # called at script start
 Draw.Register(ManageDisplay, ManageEvent, ManageWidgets)
 InitDataFile()
 DeselectAllObjects()