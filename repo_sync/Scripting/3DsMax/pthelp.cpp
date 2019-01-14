/**********************************************************************
    I think the selection bracket issue should be the least of your worries concerning points in max !
	some of the worst programming I’ve ever seen and there’s even a memory leak/bug in the post load callback when loading old files, 
	small but still a leak. The display code is appalling needless calls that do nothing and randomness all over the place.
	for anyone who wants here's some modified code that address's the issues
	 
	 
	 *<
    	FILE: pthelp.cpp
    
    	DESCRIPTION:  A point helper implementation
    
    	CREATED BY: 
    
    	HISTORY: created 14 July 1995
    
     *>	Copyright (c) 1995, All Rights Reserved.
     **********************************************************************/
    
    #include "helpers.h"
    #include "iparamb2.h"
    #include "iparamm2.h"
    #include "istdplug.h"
    
    extern HINSTANCE hInstance;
    
    #define AXIS_LENGTH 20.0f
    #define ZFACT (float).005;
    #define X_AXIS_LABEL _T("x")
    #define Y_AXIS_LABEL _T("y")
    #define Z_AXIS_LABEL _T("z")
    
    class PointHelpObject : public HelperObject 
    {
    public:		
    
    	static IObjParam *ip;
    	static PointHelpObject *editOb;
    	IParamBlock2 *pblock;
    
    // Snap suspension flag (TRUE during creation only)
    	BOOL suspendSnap;
    				
    // Old params... these are for loading old files only. Params are now stored in pb2.
    
    	BOOL showAxis;
    	float axisLength;
    
    // For use by display system
    
    	int extDispFlags;
    
    //  inherited virtual methods for Reference-management
    
    	PointHelpObject();
    	~PointHelpObject() { DeleteAllRefsFromMe(); }
    	
    // From BaseObject
    
    	int HitTest(TimeValue t, INode* inode, int type, int crossing, int flags, IPoint2 *p, ViewExp *vpt);
    	void Snap(TimeValue t, INode* inode, SnapInfo *snap, IPoint2 *p, ViewExp *vpt);
    	void SetExtendedDisplay(int flags) { extDispFlags = flags; }
    	int Display(TimeValue t, INode* inode, ViewExp *vpt, int flags);
    	CreateMouseCallBack* GetCreateMouseCallBack();
    	void BeginEditParams( IObjParam *ip, ULONG flags,Animatable *prev);
    	void EndEditParams( IObjParam *ip, ULONG flags,Animatable *next);
    	TCHAR *GetObjectName() {return GetString(IDS_POINT_HELPER_NAME);}
    
    // From Object
    
    	ObjectState Eval(TimeValue time) { return ObjectState(this); }
    	void InitNodeName(TSTR& s) { s = GetString(IDS_DB_POINT); }
    	ObjectHandle ApplyTransform(Matrix3& matrix) {return this;}
    	int CanConvertToType(Class_ID obtype) {return FALSE;}
    	Object* ConvertToType(TimeValue t, Class_ID obtype) {assert(0);return NULL;}		
    	void GetWorldBoundBox(TimeValue t, INode *mat, ViewExp *vpt, Box3& box );
    	void GetLocalBoundBox(TimeValue t, INode *mat, ViewExp *vpt, Box3& box );
    	int DoOwnSelectHilite()	{ return 1; }
    	Interval ObjectValidity(TimeValue t);
    	int UsesWireColor() {return TRUE;}
    
    // Animatable methods
    
    	void DeleteThis()				{ delete this; }
    	Class_ID ClassID()				{ return Class_ID(POINTHELP_CLASS_ID,0); }  
    	void GetClassName(TSTR& s)		{ s = TSTR(GetString(IDS_DB_POINTHELPER_CLASS)); }
    	int IsKeyable()					{ return 0;}
    	int NumSubs()					{ return 1; }  
    	Animatable* SubAnim(int i)		{ return pblock; }
    	TSTR SubAnimName(int i)			{ return TSTR(_T("Parameters"));}
    	IParamArray *GetParamBlock()	{ return (IParamArray*)pblock; }
    	int GetParamBlockIndex(int id)	{ return (pblock && id >= 0 && id < pblock->NumParams()) ? id : -1; }
    	int	NumParamBlocks()			 { return 1; }
    	IParamBlock2* GetParamBlock(int i) { return pblock; }
    	IParamBlock2* GetParamBlockByID(short id) { return pblock; }
    
    // From ref
    
    	RefTargetHandle Clone(RemapDir& remap = DefaultRemapDir());
    	IOResult Load(ILoad *iload);
    	IOResult Save(ISave *isave);
    	int NumRefs() {return 1;}
    	RefTargetHandle GetReference(int i) {return pblock;}
    	void SetReference(int i, RefTargetHandle rtarg) {pblock=(IParamBlock2*)rtarg;}
    	RefResult NotifyRefChanged( Interval changeInt, RefTargetHandle hTarget, PartID& partID, RefMessage message );
    
    // Local methods
    
    	void Draw(GraphicsWindow* gw, float size, TimeValue t);
    	void UpdateParamblockFromVars();
    };				
    
    //********************************************************************************************
    // class variable for point class.
    
    IObjParam *PointHelpObject::ip = NULL;
    PointHelpObject *PointHelpObject::editOb = NULL;
    
    //********************************************************************************************
    
    class PointHelpObjClassDesc:public ClassDesc2 
    {
    	public:
    	int 			IsPublic() { return 1; }
    	void *			Create(BOOL loading = FALSE) { return new PointHelpObject; }
    	const TCHAR *	ClassName() { return GetString(IDS_DB_POINT_CLASS); }
    	SClass_ID		SuperClassID() { return HELPER_CLASS_ID; }
    	Class_ID		ClassID() { return Class_ID(POINTHELP_CLASS_ID,0); }
    	const TCHAR* 	Category() { return _T("");  }
    	//void			ResetClassParams(BOOL fileReset) { if(fileReset) resetPointParams(); }
    	const TCHAR*	InternalName() {return _T("PointHelperObj");}
    	HINSTANCE		HInstance() {return hInstance;}			// returns owning module handle
    };
    
    static PointHelpObjClassDesc pointHelpObjDesc;
    ClassDesc* GetPointHelpDesc() { return &pointHelpObjDesc; }
    
    //********************************************************************************************
    
    #define PBLOCK_REF_NO	 0
    
    // The following two enums are transfered to the istdplug.h by AG: 01/20/2002 
    // in order to access the parameters for use in Spline IK Control modifier
    // and the Spline IK Solver
    
    // block IDs
    //enum { pointobj_params, };
    
    // pointobj_params IDs
    
    // enum { 
    //	pointobj_size, pointobj_centermarker, pointobj_axistripod, 
    //	pointobj_cross, pointobj_box, pointobj_screensize, pointobj_drawontop };
    
    // per instance block
    static ParamBlockDesc2 pointobj_param_blk( 
    	
    	pointobj_params, _T("PointObjectParameters"),  0, &pointHelpObjDesc, P_AUTO_CONSTRUCT+P_AUTO_UI, PBLOCK_REF_NO,
    
    	//rollout
    	IDD_NEW_POINTPARAM, IDS_POINT_PARAMS, 0, 0, NULL,
    
    	// params
    	pointobj_size, _T("size"), TYPE_WORLD, P_ANIMATABLE, IDS_POINT_SIZE,
    		p_default, 		20.0,	
    		p_ms_default,	20.0,
    		p_range, 		0.0f, float(1.0E30), 
    		p_ui, 			TYPE_SPINNER, EDITTYPE_UNIVERSE, IDC_POINT_SIZE, IDC_POINT_SIZESPIN, SPIN_AUTOSCALE, 
    		end, 
    
    	pointobj_centermarker, 	_T("centermarker"), TYPE_BOOL, P_ANIMATABLE, IDS_POINT_CENTERMARKER,
    		p_default, 			FALSE,
    		p_ui, 				TYPE_SINGLECHEKBOX, 	IDC_POINT_MARKER, 
    		end, 
    
    	pointobj_axistripod, 	_T("axistripod"), TYPE_BOOL, P_ANIMATABLE, IDS_POINT_AXISTRIPOD,
    		p_default, 			FALSE,
    		p_ui, 				TYPE_SINGLECHEKBOX, 	IDC_POINT_AXIS, 
    		end, 
    
    	pointobj_cross, 		_T("cross"), TYPE_BOOL, P_ANIMATABLE, IDS_POINT_CROSS,
    		p_default, 			TRUE,
    		p_ui, 				TYPE_SINGLECHEKBOX, 	IDC_POINT_CROSS, 
    		end, 
    
    	pointobj_box, 			_T("box"), TYPE_BOOL, P_ANIMATABLE, IDS_POINT_BOX,
    		p_default, 			FALSE,
    		p_ui, 				TYPE_SINGLECHEKBOX, 	IDC_POINT_BOX, 
    		end, 
    
    	pointobj_screensize,	_T("constantscreensize"), TYPE_BOOL, P_ANIMATABLE, IDS_POINT_SCREENSIZE,
    		p_default, 			FALSE,
    		p_ui, 				TYPE_SINGLECHEKBOX, 	IDC_POINT_SCREENSIZE,
    		end, 
    
    	pointobj_drawontop,		_T("drawontop"),	   TYPE_BOOL, P_ANIMATABLE, IDS_POINT_DRAWONTOP,
    		p_default, 			FALSE,
    		p_ui, 				TYPE_SINGLECHEKBOX, 	IDC_POINT_DRAWONTOP,
    		end, 
    	end
    );
    
    //********************************************************************************************
    
    PointHelpObject::PointHelpObject() : pblock(NULL), showAxis(TRUE), axisLength(10.0f), suspendSnap(FALSE)
    {
    	pointHelpObjDesc.MakeAutoParamBlocks(this);
    	SetAFlag(A_OBJ_CREATING);
    }
    
    //********************************************************************************************
    
    void PointHelpObject::BeginEditParams(IObjParam *ip, ULONG flags,Animatable *prev)
    {	
    	this->ip = ip;
    	editOb   = this;
    	pointHelpObjDesc.BeginEditParams(ip, this, flags, prev);
    }
    
    //********************************************************************************************
    		
    void PointHelpObject::EndEditParams(IObjParam *ip, ULONG flags,Animatable *next)
    {	
    	editOb   = NULL;
    	this->ip = NULL;
    	pointHelpObjDesc.EndEditParams(ip, this, flags, next);
    	ClearAFlag(A_OBJ_CREATING);
    }
    
    //********************************************************************************************
    
    RefTargetHandle PointHelpObject::Clone(RemapDir& remap) 
    {
    	PointHelpObject* newobj = new PointHelpObject();	
    	newobj->showAxis = showAxis;
    	newobj->axisLength = axisLength;
    	newobj->ReplaceReference(PBLOCK_REF_NO, remap.CloneRef(pblock));
    	BaseClone(this, newobj, remap);
    	return(newobj);
    }
    
    //********************************************************************************************
    
    void PointHelpObject::UpdateParamblockFromVars()
    {
    	SuspendAnimate();
    	AnimateOff();
    	
    	pblock->SetValue(pointobj_size, TimeValue(0), axisLength);
    	pblock->SetValue(pointobj_centermarker, TimeValue(0), TRUE);
    	pblock->SetValue(pointobj_axistripod, TimeValue(0), showAxis);
    	pblock->SetValue(pointobj_cross, TimeValue(0), FALSE);
    	pblock->SetValue(pointobj_box, TimeValue(0), FALSE);
    	pblock->SetValue(pointobj_screensize, TimeValue(0), TRUE);
    
    	ResumeAnimate();
    }
    
    //********************************************************************************************
    
    class PointHelpObjCreateCallBack: public CreateMouseCallBack 
    {
    	PointHelpObject *ob;
    	public:
    		int proc( ViewExp *vpt,int msg, int point, int flags, IPoint2 m, Matrix3& mat );
    		void SetObj(PointHelpObject *obj) { ob = obj; }
    };
    
    //********************************************************************************************
    
    int PointHelpObjCreateCallBack::proc(ViewExp *vpt,int msg, int point, int flags, IPoint2 m, Matrix3& mat ) {	
    
    	#ifdef _OSNAP
    	if (msg == MOUSE_FREEMOVE)
    	{
    		#ifdef _3D_CREATE
    			vpt->SnapPreview(m,m,NULL, SNAP_IN_3D);
    		#else
    			vpt->SnapPreview(m,m,NULL, SNAP_IN_PLANE);
    		#endif
    	}
    	#endif
    
    	if (msg==MOUSE_POINT||msg==MOUSE_MOVE) 
    	{
    		switch(point)
    		{
    			case 0: 
    			{
    				// Find the node and plug in the wire color
    				ULONG handle;
    				ob->NotifyDependents(FOREVER, (PartID)&handle, REFMSG_GET_NODE_HANDLE);
    				INode *node;
    				node = GetCOREInterface()->GetINodeByHandle(handle);
    				if (node) 
    				{
    					Point3 color = GetUIColor(COLOR_POINT_OBJ);
    					node->SetWireColor(RGB(color.x*255.0f, color.y*255.0f, color.z*255.0f));
    				}
    
    				ob->suspendSnap = TRUE;
    				#ifdef _3D_CREATE	
    					mat.SetTrans(vpt->SnapPoint(m,m,NULL,SNAP_IN_3D));
    				#else	
    					mat.SetTrans(vpt->SnapPoint(m,m,NULL,SNAP_IN_PLANE));
    				#endif				
    				break;
    			}
    			case 1:
    				#ifdef _3D_CREATE	
    					mat.SetTrans(vpt->SnapPoint(m,m,NULL,SNAP_IN_3D));
    				#else	
    					mat.SetTrans(vpt->SnapPoint(m,m,NULL,SNAP_IN_PLANE));
    				#endif
    				if (msg==MOUSE_POINT) 
    				{
    					ob->suspendSnap = FALSE;
    					return CREATE_STOP;
    				}
    				break;			
    		}
    	} 
    	else if (msg == MOUSE_ABORT) 
    		return CREATE_ABORT;
    	return CREATE_CONTINUE;
    }
    
    static PointHelpObjCreateCallBack pointHelpCreateCB;
    
    //********************************************************************************************
    
    CreateMouseCallBack* PointHelpObject::GetCreateMouseCallBack() 
    {
    	pointHelpCreateCB.SetObj(this);
    	return(&pointHelpCreateCB);
    }
    
    //********************************************************************************************
    
    void PointHelpObject::GetLocalBoundBox(TimeValue t, INode* inode, ViewExp* vpt, Box3& box ) 
    {
    	Matrix3 tm = inode->GetObjectTM(t);	
    	float size		= pblock->GetFloat(pointobj_size,t);
    	int screenSize	= pblock->GetInt(pointobj_screensize,t);
    	int axis		= pblock->GetInt(pointobj_axistripod,t); 
    
    	float zoom = 1.0f;
    	if(screenSize)
    		zoom = vpt->GetScreenScaleFactor(tm.GetTrans())*ZFACT;
    	if(zoom == 0.0f) 
    		zoom = 1.0f;
    	size *= zoom;
    	if(!axis)
    		size *= 0.5f;
    	box =  Box3(Point3(-size,-size,-size), Point3(size,size,size));
    }
    
    //********************************************************************************************
    
    void PointHelpObject::GetWorldBoundBox( TimeValue t, INode* inode, ViewExp* vpt, Box3& box )
    {
    	Matrix3 tm = inode->GetObjectTM(t);
    	Box3 lbox;
    
    	GetLocalBoundBox(t, inode, vpt, lbox);
    	box = Box3(tm.GetTrans(), tm.GetTrans());
    	for (int i=0; i<8; i++) 
    		box += lbox * tm;
    }
    
    //********************************************************************************************
    
    void PointHelpObject::Snap(TimeValue t, INode* inode, SnapInfo *snap, IPoint2 *p, ViewExp *vpt)
    {
    	if(suspendSnap)
    		return;
    
    	Matrix3 tm = inode->GetObjectTM(t);	
    	GraphicsWindow *gw = vpt->getGW();	
    	gw->setTransform(tm);
    
    	Matrix3 invPlane = Inverse(snap->plane);
    
    	// Make sure the vertex priority is active and at least as important as the best snap so far
    	if(snap->vertPriority > 0 && snap->vertPriority <= snap->priority) 
    	{
    		Point2 fp = Point2((float)p->x, (float)p->y);
    		Point2 screen2;
    		IPoint3 pt3;
    
    		Point3 thePoint(0,0,0);
    		// If constrained to the plane, make sure this point is in it!
    		if(snap->snapType == SNAP_2D || snap->flags & SNAP_IN_PLANE) 
    		{
    			Point3 test = thePoint * tm * invPlane;
    			if(fabs(test.z) > 0.0001)	// Is it in the plane (within reason)?
    				return;
    		}
    		gw->wTransPoint(&thePoint,&pt3);
    		screen2.x = (float)pt3.x;
    		screen2.y = (float)pt3.y;
    
    		// Are we within the snap radius?
    		int len = (int)Length(screen2 - fp);
    		if(len <= snap->strength) 
    		{
    			// Is this priority better than the best so far?
    			if(snap->vertPriority < snap->priority) 
    			{
    				snap->priority = snap->vertPriority;
    				snap->bestWorld = thePoint * tm;
    				snap->bestScreen = screen2;
    				snap->bestDist = len;
    			}
    			else
    			if(len < snap->bestDist)
    			{
    				snap->priority = snap->vertPriority;
    				snap->bestWorld = thePoint * tm;
    				snap->bestScreen = screen2;
    				snap->bestDist = len;
    			}
    		}
    	}
    }
    
    //********************************************************************************************
    
    static void DrawAnAxis(GraphicsWindow* gw, TCHAR* label, Point3& axis, bool z)
    {
    	Point3 v1(axis * 0.9f), v2((z ? Point3(axis.x,axis.z,-axis.y) : Point3(axis.y,-axis.x,axis.z)) * 0.1f), v[3];
    
    	gw->text(&axis, label);
    	v[0] = Point3(0.0f,0.0f,0.0f);
    	v[1] = axis;
    	gw->polyline(2, v, NULL, NULL, FALSE, NULL );	
    	v[0] = axis;
    	v[1] = v1+v2;
    	gw->polyline(2, v, NULL, NULL, FALSE, NULL );
    	v[0] = axis;
    	v[1] = v1-v2;
    	gw->polyline(2, v, NULL, NULL, FALSE, NULL );
    }
    
    //********************************************************************************************
    
    void PointHelpObject::Draw(GraphicsWindow* gw, float size, TimeValue t)
    {
    	Point3 pt(0,0,0), pts[5];
    
    	int centerMarker	= pblock->GetInt(pointobj_centermarker,t);
    	int axisTripod		= pblock->GetInt(pointobj_axistripod,t); 
    	int cross			= pblock->GetInt(pointobj_cross,t);
    	int box				= pblock->GetInt(pointobj_box,t);
    	
    	if(axisTripod) 
    	{
    		DrawAnAxis(gw, X_AXIS_LABEL, Point3(size,0.0f,0.0f),false);	
    		DrawAnAxis(gw, Y_AXIS_LABEL, Point3(0.0f,size,0.0f),false);	
    		DrawAnAxis(gw, Z_AXIS_LABEL, Point3(0.0f,0.0f,size),true);
    	}
    
    	if(centerMarker) 	
    		gw->marker(&pt,X_MRKR);
    
    	size *= 0.5f;
    	if (cross) 
    	{
    // X
    		pts[0] = Point3(-size, 0.0f, 0.0f); 
    		pts[1] = Point3(size, 0.0f, 0.0f);
    		gw->polyline(2, pts, NULL, NULL, FALSE, NULL);
    
    // Y
    		pts[0] = Point3(0.0f, -size, 0.0f); 
    		pts[1] = Point3(0.0f, size, 0.0f);
    		gw->polyline(2, pts, NULL, NULL, FALSE, NULL);
    
    // Z
    		pts[0] = Point3(0.0f, 0.0f, -size); 
    		pts[1] = Point3(0.0f, 0.0f, size);
    		gw->polyline(2, pts, NULL, NULL, FALSE, NULL);
    	}
    
    	if(box) 
    	{
    		size *= 0.5f;
    // Bottom
    		pts[0] = Point3(-size, -size, -size); 
    		pts[1] = Point3(-size,  size, -size);
    		pts[2] = Point3( size,  size, -size);
    		pts[3] = Point3( size, -size, -size);
    		gw->polyline(4, pts, NULL, NULL, TRUE, NULL);
    // Top
    		pts[0] = Point3(-size, -size,  size); 
    		pts[1] = Point3(-size,  size,  size);
    		pts[2] = Point3( size,  size,  size);
    		pts[3] = Point3( size, -size,  size);
    		gw->polyline(4, pts, NULL, NULL, TRUE, NULL);
    // Sides
    		pts[0] = Point3(-size, -size, -size); 
    		pts[1] = Point3(-size, -size,  size);
    		gw->polyline(2, pts, NULL, NULL, FALSE, NULL);
    
    		pts[0] = Point3(-size,  size, -size); 
    		pts[1] = Point3(-size,  size,  size);
    		gw->polyline(2, pts, NULL, NULL, FALSE, NULL);
    
    		pts[0] = Point3( size,  size, -size); 
    		pts[1] = Point3( size,  size,  size);
    		gw->polyline(2, pts, NULL, NULL, FALSE, NULL);
    
    		pts[0] = Point3( size, -size, -size); 
    		pts[1] = Point3( size, -size,  size);
    		gw->polyline(2, pts, NULL, NULL, FALSE, NULL);
    	}
    }
    
    //********************************************************************************************
    
    int PointHelpObject::HitTest( TimeValue t, INode *inode, int type, int crossing, int flags, IPoint2 *p, ViewExp *vpt) 
    {
    	HitRegion hitRegion;
    	GraphicsWindow *gw = vpt->getGW();
    	float size			= pblock->GetFloat(pointobj_size,t);
    	int screenSize		= pblock->GetInt(pointobj_screensize,t);
    	//int drawOnTop		= pblock->GetInt(pointobj_drawontop,t);
    	Matrix3 tm = inode->GetObjectTM(t);
    	
    	MakeHitRegion(hitRegion, type, crossing, 4, p);
    	if(screenSize)
    	{
    		float zoom = vpt->GetScreenScaleFactor(tm.GetTrans()) * ZFACT;
    		tm.Scale(Point3(zoom,zoom,zoom));
    	}
    	gw->setTransform(tm);
    
    	int limits = gw->getRndLimits();
    	gw->setRndLimits((limits|GW_PICK)&~GW_ILLUM);
    	gw->setHitRegion(&hitRegion);
    	gw->clearHitCode();
    
    	Draw(gw,size,t);
    	gw->setRndLimits(limits);
    	return gw->checkHitCode();
    }
    
    //********************************************************************************************
    
    int PointHelpObject::Display(TimeValue t, INode* inode, ViewExp *vpt, int flags) 
    {
    	GraphicsWindow *gw = vpt->getGW();
    	float size			= pblock->GetFloat(pointobj_size,t);
    	int screenSize		= pblock->GetInt(pointobj_screensize,t);
    	int drawOnTop		= pblock->GetInt(pointobj_drawontop,t);
    	Color color(inode->GetWireColor());	
    	Matrix3 tm = inode->GetObjectTM(t);
    	
    	if(screenSize)
    	{
    		float zoom = vpt->GetScreenScaleFactor(tm.GetTrans()) * ZFACT;
    		tm.Scale(Point3(zoom,zoom,zoom));
    	}
    	gw->setTransform(tm);
    
    	int limits = gw->getRndLimits();
    	if(drawOnTop) 
    		gw->setRndLimits(limits & ~GW_Z_BUFFER);
    
    	gw->setColor(TEXT_COLOR, GetFreezeColor());
    	gw->setColor(LINE_COLOR, GetFreezeColor());
    	if(inode->Selected()) 
    	{
    		gw->setColor( TEXT_COLOR, GetSelColor());
    		gw->setColor( LINE_COLOR, GetSelColor());
    	} 
    	else if(!inode->IsFrozen() && !inode->Dependent()) 
    	{	
    		gw->setColor( TEXT_COLOR, color);
    		gw->setColor( LINE_COLOR, color);
    	}	
    	Draw(gw,size,t);
    	gw->setRndLimits(limits);
    	return 0;
    }
    
    //********************************************************************************************
    // Reference Managment:
    // This is only called if the object MAKES references to other things.
    
    RefResult PointHelpObject::NotifyRefChanged( Interval changeInt, RefTargetHandle hTarget, PartID& partID, 
    											RefMessage message ) 
    {
    	switch (message) 
    	{
    		case REFMSG_CHANGE:
    			if (editOb==this) 
    				pointobj_param_blk.InvalidateUI(pblock->LastNotifyParamID());
    			break;
    	}
    	return(REF_SUCCEED);
    }
    
    //********************************************************************************************
    
    Interval PointHelpObject::ObjectValidity(TimeValue t)
    {
    	Interval ivalid = FOREVER;
    	pblock->GetValidity(t, ivalid);
    	return ivalid;
    }
    
    //********************************************************************************************
    
    class PointHelperPostLoadCallback : public PostLoadCallback 
    {
    public:
    
    	PointHelpObject *pobj;
    	PointHelperPostLoadCallback(PointHelpObject *p) { pobj = p; }
    	void proc(ILoad *iload) { pobj->UpdateParamblockFromVars(); delete this; }
    };
    
    //********************************************************************************************
    
    #define SHOW_AXIS_CHUNK				0x0100
    #define AXIS_LENGTH_CHUNK			0x0110
    #define POINT_HELPER_R4_CHUNKID		0x0120 // new version of point helper for R4 (updated to use PB2)
    
    IOResult PointHelpObject::Load(ILoad *iload)
    {
    	ULONG nb;
    	IOResult res = IO_OK;
    	BOOL oldVersion = TRUE;
    
    	while (IO_OK==(res=iload->OpenChunk())) 
    	{
    		switch (iload->CurChunkID()) 
    		{
    			case SHOW_AXIS_CHUNK:
    				res = iload->Read(&showAxis,sizeof(showAxis),&nb);
    				break;
    
    			case AXIS_LENGTH_CHUNK:
    				res = iload->Read(&axisLength,sizeof(axisLength),&nb);
    				break;
    
    			case POINT_HELPER_R4_CHUNKID:
    				oldVersion = FALSE;
    				break;
    		}
    		res = iload->CloseChunk();
    		if(res!=IO_OK)  
    			return res;
    	}
    	
    	if (oldVersion) 
    		iload->RegisterPostLoadCallback(new PointHelperPostLoadCallback(this));
    
    	return IO_OK;
    }
    
    //********************************************************************************************
    
    IOResult PointHelpObject::Save(ISave *isave)
    {
    	isave->BeginChunk(POINT_HELPER_R4_CHUNKID);
    	isave->EndChunk();
    	
    	return IO_OK;
    }
    
    //********************************************************************************************
    