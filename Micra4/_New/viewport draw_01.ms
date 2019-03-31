vp_size = [gw.getWinSizeX() as float, gw.getWinSizeY() as float] --equal
vp_size = getViewSize() --equal
IsPerspView
isPerspectiveView
gw.hTransPoint (polyOp.getvert $ 10)

fn getViewDirectionRay = (
	-- The affine TM transforms from world coords to view coords
	local coordSysTM = Inverse(getViewTM()) -- so we need the inverse of this matrix
	local viewDir = -coordSysTM.row3 -- The Z axis of this matrix is the view direction.
	local viewPt = coordSysTM.row4 -- get the view position from this matrix
	return ray viewPt viewDir
)


--Print the HWND Handles of all valid viewports:
for i = 1 to viewport.numViews do 
    format "HWND of Viewport % is %\n" i (viewport.getHWnd index:i)

--Snapshot the valid viewports:
for i = 1 to viewport.numViews do
    display (windows.snapshot (viewport.getHWnd index:i)) caption:("Viewport "+i as string)