
// Move stuff
private bool		movingForm;
private Point		formOffsetPoint;	// calculated offset rect to be added !! (min distances in all directions!!)
private Point		offsetPoint;		// primary offset

// General Stuff
private Form		originalForm;		// the form
private Rectangle	formRect;			// form bounds
private Rectangle	formOriginalRect;	// bounds before last operation started

// public properties
private static int	stickGap = 20;		// distance to stick
private bool		stickOnMove;
private bool		stickToOther;

//Global List of registered StickyWindows
private static ArrayList	GlobalStickyWindows = new ArrayList();




/// <param name="calculatedOffset">Calculate positon of the offset (snap distance)</param>
/// <param name="toRect">Rect to try to snap to</param>
/// <param name="bInsideStick">Allow snapping on the inside (eg: window to screen)</param>
private void Move_Stick ( Rectangle toRect, bool bInsideStick )
{
	// compare distance from toRect to formRect
	// and then with the found distances, compare the most closed position
	if ( formRect.Bottom >= (toRect.Top - stickGap) && formRect.Top <= (toRect.Bottom + stickGap) )
	{
		if ( bInsideStick )
		{
			if ( (Math.Abs(formRect.Left - toRect.Right) <= Math.Abs(formOffsetPoint.X) ) )
			{	// left 2 right
				formOffsetPoint.X = toRect.Right - formRect.Left;
			}
			if ( (Math.Abs(formRect.Left + formRect.Width - toRect.Left) <= Math.Abs(formOffsetPoint.X) ) )
			{	// right 2 left
				formOffsetPoint.X = toRect.Left - formRect.Width - formRect.Left;
			}
		}

		if ( Math.Abs(formRect.Left - toRect.Left) <= Math.Abs(formOffsetPoint.X) )
		{	// snap left 2 left
			formOffsetPoint.X = toRect.Left - formRect.Left;
		}
		if ( Math.Abs(formRect.Left + formRect.Width - toRect.Left - toRect.Width ) <= Math.Abs(formOffsetPoint.X))
		{	// snap right 2 right
			formOffsetPoint.X = toRect.Left + toRect.Width - formRect.Width - formRect.Left;
		}
	}
	if ( formRect.Right >= (toRect.Left - stickGap) && formRect.Left <= (toRect.Right + stickGap) )
	{
		if ( bInsideStick )
		{
			if (Math.Abs(formRect.Top - toRect.Bottom) <= Math.Abs(formOffsetPoint.Y) && bInsideStick )
			{	// Stick Top to Bottom
				formOffsetPoint.Y = toRect.Bottom - formRect.Top;
			}
			if (Math.Abs(formRect.Top + formRect.Height - toRect.Top) <= Math.Abs(formOffsetPoint.Y) && bInsideStick )
			{	// snap Bottom to Top
				formOffsetPoint.Y =  toRect.Top - formRect.Height - formRect.Top;
			}
		}

		// try to snap top 2 top also
		if (Math.Abs(formRect.Top - toRect.Top) <= Math.Abs(formOffsetPoint.Y))
		{	// top 2 top
			formOffsetPoint.Y =  toRect.Top - formRect.Top;
		}
		if ( Math.Abs(formRect.Top + formRect.Height - toRect.Top - toRect.Height ) <= Math.Abs(formOffsetPoint.Y))
		{	// bottom 2 bottom
			formOffsetPoint.Y =  toRect.Top + toRect.Height - formRect.Height - formRect.Top;
		}
	}
}


private int NormalizeInside ( int iP1, int iM1, int iM2 )
{
	if ( iP1 <= iM1 )
		return iM1;
	else
		if ( iP1 >= iM2 )
			return iM2;
	return iP1;
}

private void Move( Point p )
{
	p = originalForm.PointToScreen ( p );
	Screen activeScr = Screen.FromPoint ( p );	// get the screen from the point !!

	if ( !activeScr.WorkingArea.Contains ( p ) )
	{
		p.X = NormalizeInside ( p.X, activeScr.WorkingArea.Left, activeScr.WorkingArea.Right );
		p.Y = NormalizeInside ( p.Y, activeScr.WorkingArea.Top, activeScr.WorkingArea.Bottom );
	}

	p.Offset ( -offsetPoint.X, -offsetPoint.Y );

	// p is the exact location of the frame - so we can play with it
	// to detect the new position acording to different bounds
	formRect.Location = p;	// this is the new positon of the form

	formOffsetPoint.X	= stickGap + 1;	// (more than) maximum gaps
	formOffsetPoint.Y	= stickGap + 1;

	if ( stickToScreen )
		Move_Stick ( activeScr.WorkingArea, false );

	// Now try to snap to other windows
	if ( stickToOther )
	{
		foreach ( Form sw in GlobalStickyWindows )
		{
			if ( sw != this.originalForm )
				Move_Stick( sw.Bounds, true );
		}
	}

	if ( formOffsetPoint.X == stickGap+1 )
		formOffsetPoint.X = 0;
	if ( formOffsetPoint.Y == stickGap+1 )
		formOffsetPoint.Y = 0;

	formRect.Offset ( formOffsetPoint );

	originalForm.Bounds = formRect;
}