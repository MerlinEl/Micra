from Py3dsMax import mxs 

# newSpline = drawLineBetweenTwoPoints( mxs.Point3( 10, 20, 30 ), mxs.Point3( 100, 200, 10 ) )
def drawLineBetweenTwoPoints( pointA, pointB ):
	ss = mxs.SplineShape( pos = pointA )
	mxs.addNewSpline( ss )
	# Create name instances from maxscript using the global namify method
	corner = mxs.namify( 'corner' )
	line		= mxs.namify( 'line' )	
	mxs.addKnot( ss, 1, corner, line, pointA )
	mxs.addKnot( ss, 1, corner, line, pointB )
	mxs.updateShape( ss )
	return ss