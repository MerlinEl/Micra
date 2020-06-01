using Autodesk.Max;
using Micra.Core;
using System;
using System.Collections.Generic;
using System.Linq;
//https://referencesource.microsoft.com/#PresentationCore
//https://docs.arnoldrenderer.com/display/A5AF3DSUG/Math+Maps
//https://www.scriptspot.com/bobo/mel2mxs/arithmetic.htm
namespace Micra.Tools {
    public class MxMath {

        internal static double RadToDeg(double radians) {
            return radians * ( 180.0 / Math.PI );
        }

        internal static double DegToRad(double degrees) {
            return degrees * ( Math.PI / 180.0 );
        }

        //Compute the dot product between two vectors as follows: 
        public static float Dot(Point3 v1, Point3 v2) { //OK

            return ( v1.X * v2.X ) + ( v1.Y * v2.Y ) + ( v1.Z * v2.Z );
        }
        //Compute the cross product between two vectors, defined as the vector perpendicular to both input vectors, 
        //with its direction defined by the right-hand rule.
        public static Point3 Cross(Point3 v1, Point3 v2) { //OK

            return new Point3(
                ( v1.Y * v2.Z ) - ( v1.Z * v2.Y ),
                ( v1.Z * v2.X ) - ( v1.X * v2.Z ),
                ( v1.X * v2.Y ) - ( v1.Y * v2.X )
            );
        }
    }
}


/*public static float GetAreaFromPoints(List<IPoint3> points) { //not used not tested

    return Math.Abs(points
        .Take(points.Count - 1)
        .Select((p, i) => ( points[i + 1].X - p.X ) * ( points[i + 1].Y + p.Y ))
        .Sum() / 2);
}*/
/*
fn pointToBary p a b c = 
(
	vw = cross (c - a) (p - a)
	uw = cross (b - a) (p - a)
	uv = cross (b - a) (c - a)

	denom = length uv
	r = (length vw)/denom
	t = (length uw)/denom
	[1-r-t,r,t]
)
fn baryToPoint p a b c = (p.x*a + p.y*b + p.z*c)
 *  */
