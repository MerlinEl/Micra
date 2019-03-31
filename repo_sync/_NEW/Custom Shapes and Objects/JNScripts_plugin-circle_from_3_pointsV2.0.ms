--------------------------------------------------------------------------------
--    Circle from 3 points
--    version 2.0
--    max version 6
--    written by Joshua Newman
--    josh@here.net.au
--    www.joshuanewman.net
--    last updated 29/09/04
--    copyright 2004
--------------------------------------------------------------------------------
--
-- creates a circle using three points.
--
--------------------------------------------------------------------------------
-- Installation:
--
-- place this file in any of your plugins folders.
--
--------------------------------------------------------------------------------
-- Usage:
--
-- You will find this under the create panel / shapes / Circle 3 point
-- click mouse button for each point. will create a circle on a plane defined
-- by the three points in 3D space
--
--------------------------------------------------------------------------------
-- History:
--
-- 29/09/04
-- fixed creation technique to click click click method.
-- fixed auto plane feature thanks to James Coulter jcoulter@digitaldimension.com
-- 27/09/04
-- Started writing plugin
--
--------------------------------------------------------------------------------
-- Acknowledgements:
--
-- James Coulter jcoulter@digitaldimension.com for debugging my vector maths
-- Alex Mcleod for supplying the basic circle three points function
--
--------------------------------------------------------------------------------

plugin shape circle3
name:"Circle 3 points"
version:1
classID:#(0x24f408ae, 0x4f051b77)
extends:circle
category:"Splines"
(
	fn getnormal3pts p1 p2 p3=
	(
		v3=normalize (p3-p1)
		v2=normalize (p2-p1)
		return normalize (cross v2 v3)
	)
	fn makecircle aIn bIn cIn = 
	(
		Pre = matrixfromnormal (getnormal3pts aIn bIn cIn)
		Pre.pos = aIn
		
		a = aIn * (inverse Pre)
		b = bIn * (inverse Pre)
		c = cIn * (inverse Pre)

		p=[0,0,0]
		va = b.x - a.x
		vb = b.y - a.y
		vc = c.x - a.x
		d = c.y - a.y
		
		ve = va*(a.x + b.x) + vb*(a.y + b.y)
		f = vc*(a.x + c.x) + d*(a.y + c.y)
		
		g = 2.0*(va*(c.y - b.y)-vb*(c.x - b.x))
		p.x = (d*ve - vb*f) / g
		p.y = (va*f - vc*ve) / g

		return ( [p.x, p.y, 0.0] * Pre )
	)
	tool create 
	( 
		local p1,p2,p3,startpoint
		on mousePoint click do 
		case click of 
		( 
			1: p1=gridpoint
			3: p2=gridpoint

			4: #stop
		)
		on mousemove click do 
		case click of 
		(
			4:
			(
				nodetm.rotation=(matrixfromnormal (getnormal3pts p1 p2 gridpoint)).rotation
				nodetm.translation=(makecircle p1 p2 gridpoint)
				delegate.radius=(distance p1 nodetm.translation)
			)
		)
	) 
) 
