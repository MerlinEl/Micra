using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Media.Media3D;
//https://docs.arnoldrenderer.com/display/A5AF3DSUG/Math+Maps
//https://www.scriptspot.com/bobo/mel2mxs/arithmetic.htm
namespace Micra.Tools {
    public class MxMath {


        public static Vector3D VectorFromPoints(IPoint3 P1, IPoint3 P2) {

            return new Vector3D(
                P1.X - P2.X,
                P1.Y - P2.Y,
                P1.Z - P2.Z
            );
        }
        internal static Vector3D VectorFromPoint(IPoint3 p) => new Vector3D(p.X, p.Y, p.Z);

        //Compute the dot product between two vectors as follows: 
        //a⋅b=a x b x +a y b y +a z b z   
        public static float Dot(IPoint3 V1, IPoint3 V2) { //not used not tested

            return (V1.X * V2.X) +(V1.Y * V2.Y) +(V1.Z * V2.Z);
        }
        //Compute the cross product between two vectors, defined as the vector perpendicular to both input vectors, with its direction defined by the right-hand rule.
        public static IPoint3 Cross(IPoint3 V1, IPoint3 V2) { //not used not tested
            IPoint3 p = MxGet.NewPoint3(
                ( V1.Y * V2.Z ) - ( V1.Z * V2.Y ), 
                ( V1.Z * V2.X ) - ( V1.X * V2.Z ), 
                ( V1.X * V2.Y ) - ( V1.Y * V2.X ));
            return p;
        }

            public static float GetAreaFromPoints(List<IPoint3> points) { //not used not tested

            return Math.Abs(points
                .Take(points.Count - 1)
                .Select((p, i) => ( points[i + 1].X - p.X ) * ( points[i + 1].Y + p.Y ))
                .Sum() / 2);
        }


    }
}


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
