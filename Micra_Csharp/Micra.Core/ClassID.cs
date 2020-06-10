//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System;
using System.Linq;
using System.Reflection;

namespace Micra.Core {
    /// <summary>
    /// Identifies a particular plug-in. Wraps the Class_ID class in the 3sd Max SDK.
    /// </summary>
    [Serializable]
    public struct ClassID {
        public uint a;
        public uint b;
        public ClassID(Autodesk.Max.IClass_ID id) : this(id.PartA, id.PartB) { }
        public ClassID(uint a, uint b) { this.a = a; this.b = b; }
        public ClassID(BuiltInClassIDA a, BuiltInClassIDB b) { this.a = (uint)a; this.b = (uint)b; }
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

        public IClass_ID _IClass_ID => Kernel._Global.Class_ID.Create(a, b);

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
        //public static ClassID LineShape = new ClassID(BuiltInClassIDA.SPLINE3D_CLASS_ID, 0);
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
            return GetIClassNames(clsID) + "- This Class is not Registed in ClassID. VIP.";
        }
        /// <summary>usage: Get Name from a ClasID as Max Name</summary>
        public string GetIClassNames(ClassID clsID) {
            //get clas name from Max Enums
            Type t = typeof(BuiltInClassIDA);
            return Enum.GetName(t, clsID.a) + " | " + Enum.GetName(t, clsID.b);
        }
        /// <summary> Get All ClassID Names</summary>
        public static string[] GetClassNames() {

            Type type = typeof(ClassID);
            return type.GetFields(BindingFlags.Static | BindingFlags.Public)
                .Where(f => f.FieldType == type)
                .Select(f => f.Name)
                .ToArray();
        }

        public override string ToString() {
            return "ClassID(" + a.ToString() + ", " + b.ToString() + ")";
        }

        public bool Equals(IClass_ID icid) {

            //Kernel.WriteLine("Equal test PartA:{0} PartB:{1} a:{2} b:{3}", icid.PartA, icid.PartB, a, b);
            return icid.PartA == a && icid.PartB == b;
        }

        public override bool Equals(object obj) {
            if ( !( obj is ClassID ) )
                return false;
            ClassID that = (ClassID)obj;
            return a == that.a && b == that.b;
        }

        public override int GetHashCode() {
            return a.GetHashCode() ^ b.GetHashCode();
        }

        public static bool operator ==(ClassID x, ClassID y) { return ( x.a == y.a ) && ( x.b == y.b ); }
        public static bool operator !=(ClassID x, ClassID y) { return ( x.a != y.a ) || ( x.b != y.b ); }
    }
}
