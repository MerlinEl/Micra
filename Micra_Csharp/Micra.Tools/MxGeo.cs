namespace Micra.Tools {
    public class MxGeo {
    }
}


/*public static IPoint3 Point(double x, double y, double z) {

    return Global.Point3.Create(x, y, z);
}*/

/*public static IPoint3 ToPoint3(this Vector3 value) {


    return Global.Point3.Create(value.X, value.Y, value.Z);
}*/


/*public class Point {
    private double _x = 0;
    private double _y = 0;
    private double _z = 0;
  *  private IPoint3 p;
    public Point(double x, double y, double z) {
        _x = x;
        _y = y;
        _z = z;
        p = MxGet.Global.Point3.Create(x, y, z);
    }
}*/


    /*
     /// <summary>
        /// Method to get an IPolyLine from a Shape (after modifiers applyed).
        /// </summary>
        /// <param name="shapeNode"></param>   The shape node
        /// <param name="numSpline"></param>   The index of the ISpline3D to get from the shape
        /// <param name="numsteps"></param>   The number of setps to apply for the conversion
        /// <returns> the 'ns' ISpline3D of the shape converted to IPolyLine (or the first one if ns>number of splines in the shape)</returns>
        /// 
        public static IPolyLine ConvertShapeToIPolyLine(IINode shapeNode, int numSpline, int numsteps)
        {

            ISplineShape newSpline1 = GetSplineShapeFromNode(shapeNode);

            if (isShape)
            {
                //MyClass("ISplineShape newSpline1", newSpline1);   //Inspects the Shape BaseObject. 

                SClass_ID mySClass1 = SClass_ID.Shape;  //shape SuperClass
                IClass_ID myClass1 = global.Class_ID.Create((uint)BuiltInClassIDA.SPLINE3D_CLASS_ID, 0);    //ISpline3D class

                IBezierShape bzs = newSpline1.Shape;    //IBezierShape got from ISplineShape newSpline1

                IClass_ID myClass2 = global.Class_ID.Create((uint)BuiltInClassIDA.LINEARSHAPE_CLASS_ID, 0); //ILinearShape class
                ILinearShape iln = ip.CreateInstance(mySClass1, myClass2) as ILinearShape;
                IPolyShape pshp = iln.Shape;    // Creates empty IPolyShape from empty ILinearShape

                bzs.MakePolyShape(pshp, numsteps, false);   //Get the IPolyShape from the IBezierShape

                if (numSpline < 0 || numSpline > (pshp.NumLines - 1))
                {
                    numSpline = 0;
                }

                IPolyLine the_Path = pshp.Lines[numSpline]; //Gets the IPolyLine from the IPolyShape

                
                //int numPoints = the_Path.NumPts;
                //List<IPoint3> thePoints = new List<IPoint3>(nsp4);

                //for (int i = 0; i < numPoints; i++)
                //{
                //    IPoint3 p1 = the_Path.Pts[i].P;
                //    thePoints.Add(p1);
                //}
                

                return (the_Path);
            }
            else
            {
                //WriteLine("The Node is not a Shape");
                return null;
            }
        }


     */