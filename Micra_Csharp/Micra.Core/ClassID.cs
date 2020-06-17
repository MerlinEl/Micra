//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace Micra.Core {
    /// <summary> Identifies a particular plug-in. Wraps the Class_ID class in the 3sd Max SDK.
    ///     <example> 
    ///         <code>
    ///             example: 
    ///             switch ( node.ClassOf() ) {
    ///                 <br>case nameof(ClassID.EditablePoly) : Max.Log("is poly"); break;</br>
    ///                 <br>case nameof(ClassID.EditableMesh) : Max.Log("is mesh"); break;</br>
    ///             <br>}</br>
    ///         </code>
    ///     </example>
    /// </summary>
    [Serializable]
    public struct ClassID {
        /*switch ( node.ClassOf() ) {
            case ClassID.ClassName.EditablePoly: MaxLog("is poly"); break;
        }*/
        /*public enum ClassName {

            EditableMesh,
            EditablePoly
        }*/
        public uint PartA;
        public uint PartB;
        public ClassID(IClass_ID id) : this(id.PartA, id.PartB) { }
        public ClassID(uint a, uint b) { this.PartA = a; this.PartB = b; }
        public ClassID(BuiltInClassIDA a, BuiltInClassIDB b) { this.PartA = (uint)a; this.PartB = (uint)b; }
        /// <summary>usage: Create ClassID from Name
        /// <example>
        /// <code>example: 
        /// ClassID classId = ClassID.FromName("EditableMesh");
        /// </code> 
        /// </example>
        ///	<returns>result:new ClassID</returns>	
        /// <param name="className">ClassID Name</param>
        /// </summary>
        public static ClassID FromName(string className) {

            Type type = typeof(ClassID);
            FieldInfo fi = type
                .GetFields(BindingFlags.Static | BindingFlags.Public)
                .Where(f => f.FieldType == type && f.Name == className).FirstOrDefault();
            return fi != null ? (ClassID)fi.GetValue(fi) : new ClassID();
        }

        public IClass_ID _IClass_ID => Kernel._Global.Class_ID.Create(PartA, PartB);

        //is class
        public static ClassID EditableMesh = new ClassID(BuiltInClassIDA.EDITTRIOBJ_CLASS_ID, 0);
        public static ClassID EditablePoly = new ClassID(BuiltInClassIDA.EPOLYOBJ_CLASS_ID, BuiltInClassIDB.EPOLYOBJ_CLASS_ID);
        public static ClassID BoneObject = new ClassID(BuiltInClassIDA.BONE_OBJ_CLASSID, BuiltInClassIDB.BONE_OBJ_CLASSID);
        public static ClassID TargetObject = new ClassID(BuiltInClassIDA.TARGET_CLASS_ID, 0);
        public static ClassID SpotLight = new ClassID(BuiltInClassIDA.SPOT_LIGHT_CLASS_ID, 0);
        public static ClassID OmniLight = new ClassID(BuiltInClassIDA.OMNI_LIGHT_CLASS_ID, 0);
        public static ClassID PointHelper = new ClassID(BuiltInClassIDA.EXPR_POS_CONTROL_CLASS_ID, 0);
        public static ClassID DummyHelper = new ClassID(BuiltInClassIDA.DUMMY_CLASS_ID, 0);
        public static ClassID TapeHelper = new ClassID(BuiltInClassIDA.TAPEHELP_CLASS_ID, 0);
        //primitive classes
        public static ClassID SplineShape = new ClassID(BuiltInClassIDA.SPLINE3D_CLASS_ID, 0);
        public static ClassID CircleShape = new ClassID(BuiltInClassIDA.CIRCLE_CLASS_ID, 0);
        public static ClassID ElipseShape = new ClassID(BuiltInClassIDA.ELLIPSE_CLASS_ID, 0);
        public static ClassID RectangleShape = new ClassID(BuiltInClassIDA.RECTANGLE_CLASS_ID, 0);
        public static ClassID DonutShape = new ClassID(BuiltInClassIDA.DONUT_CLASS_ID, 0);
        public static ClassID SphereObj = new ClassID(BuiltInClassIDA.SPHERE_CLASS_ID, 0);
        public static ClassID CylinderObject = new ClassID(BuiltInClassIDA.DMTL2_CLASS_ID, 0);
        public static ClassID BoxObject = new ClassID(BuiltInClassIDA.BOXOBJ_CLASS_ID, 0);
        //can convert
        public static ClassID TriObject = new ClassID(BuiltInClassIDA.TRIOBJ_CLASS_ID, 0);
        public static ClassID PolyObject = new ClassID(BuiltInClassIDA.POLYOBJ_CLASS_ID, 0);
        public static ClassID TeapotObject = new ClassID(BuiltInClassIDA.TEAPOT_CLASS_ID, BuiltInClassIDB.TEAPOT_CLASS_ID);

        public string GetClassName() => GetClassName(new ClassID(PartA, PartB));
            /// <summary>usage: Get a Name from current ClasID as Kenel Name</summary>
            public string GetClassName(ClassID clsID) {
            //get Clas name From Kernel Struct
            Type type = typeof(ClassID);
            foreach ( var p in type.GetFields(BindingFlags.Static | BindingFlags.Public) ) {
                var v = p.GetValue(null); // static classes cannot be instanced, so use null...
                if ( v.ToString() == clsID.ToString() ) {
                    return p.Name;
                }
            }
            //if class not found in ClassID, provide original Max BuiltInClassIDA Name
            return GetIClassName(clsID) + "- This Class is not Registed in ClassID. VIP.";
        }
        /// <summary>usage: Get Name from a ClasID as Max Name</summary>
        public string GetIClassName(ClassID clsID) {
            //get clas name from Max Enums
            Type t = typeof(BuiltInClassIDA);
            return Enum.GetName(t, clsID.PartA) + " | " + Enum.GetName(t, clsID.PartB);
        }

        public override string ToString() {
            return "ClassID(" + PartA.ToString() + ", " + PartB.ToString() + ")";
        }

        public bool Equals(IClass_ID icid) {

            //Max.Log("Equal test PartA:{0} PartB:{1} a:{2} b:{3}", icid.PartA, icid.PartB, a, b);
            return icid.PartA == PartA && icid.PartB == PartB;
        }

        public override bool Equals(object obj) {
            if ( !( obj is ClassID ) ) return false;
            ClassID that = (ClassID)obj;
            return PartA == that.PartA && PartB == that.PartB;
        }

        public override int GetHashCode() => PartA.GetHashCode() ^ PartB.GetHashCode();

        public static bool operator ==(ClassID x, ClassID y) { return ( x.PartA == y.PartA ) && ( x.PartB == y.PartB ); }
        public static bool operator !=(ClassID x, ClassID y) { return ( x.PartA != y.PartA ) || ( x.PartB != y.PartB ); }

  

        //internal static int GetID(ClassID clsID) => (int)( clsID.a + clsID.b );
        //internal int GetID() => (int)( a + b );
    }
}


/* Custom Enum Type
public static class EnumExtensions
{
    public static TAttribute GetAttribute<TAttribute>(this Enum value)
        where TAttribute : Attribute
    {
        var type = value.GetType();
        var name = Enum.GetName(type, value);
        return type.GetField(name) // I prefer to get attributes this way
            .GetCustomAttributes(false)
            .OfType<TAttribute>()
            .SingleOrDefault();
    }
}

public static class EnumExtensions
{
    public static TAttribute GetAttribute<TAttribute>(this Enum value)
        where TAttribute : Attribute
    {
        var type = value.GetType();
        var name = Enum.GetName(type, value);
        return type.GetField(name) // I prefer to get attributes this way
            .GetCustomAttribute<TAttribute>();
    }
}

public class PlanetInfoAttribute : Attribute
{
    internal PlanetInfoAttribute(double mass, double radius)
    {
        this.Mass = mass;
        this.Radius = radius;
    }
    public double Mass { get; private set; }
    public double Radius { get; private set; }
}


public enum Planet
{
    [PlanetInfo(3.303e+23, 2.43970e6)]  Mecury,
    [PlanetInfo(4.869e+24, 6.05180e6)]  Venus,
    [PlanetInfo(5.976e+24, 6.37814e6)]  Earth,
    [PlanetInfo(6.421e+23, 3.39720e6)]  Mars,
    [PlanetInfo(1.900e+27, 7.14920e7)]  Jupiter,
    [PlanetInfo(5.688e+26, 6.02680e7)]  Saturn,
    [PlanetInfo(8.686e+25, 2.55590e7)]  Uranus,
    [PlanetInfo(1.024e+26, 2.47460e7)]  Neptune,
    [PlanetInfo(1.270e+22, 1.13700e6)]  Pluto,
}

public static class PlanetExtensions
{
    public static double GetSurfaceGravity(this Planet p)
    {
        var attr = p.GetAttribute<PlanetInfoAttribute>();
        return G * attr.Mass / (attr.Radius * attr.Radius);
    }

    public static double GetSurfaceWeight(this Planet p, double otherMass)
    {
        return otherMass * p.GetSurfaceGravity();
    }

    public const double G = 6.67300E-11;
}

*/
