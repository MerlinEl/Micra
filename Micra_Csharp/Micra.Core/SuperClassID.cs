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
    /// <summary>
    /// Identifies a category of plug-in type. Wraps the SClass_ID class in the 3ds Max SDK. 
    /// </summary>
    [Serializable]
    public struct SuperClassID {
        public ulong id;
        public SuperClassID(SClass_ID id) { this.id = (ulong)id; }
        public static implicit operator SuperClassID(SClass_ID id) { return new SuperClassID(id); }
        public static implicit operator SClass_ID(SuperClassID id) { return (SClass_ID)id.id; }
        /// <summary>
        /// usage: Create SuperClassID from Name
        /// <example>
        /// <code>
        /// example: SuperClassID superClassId = SuperClassID.FromName("Light");
        /// </code>
        /// </example>
        /// <param name="sclassName"></param>
        /// <returns>return: new SuperClassID</returns>
        /// </summary>
        public static SuperClassID FromName(string sclassName) {

            Type type = typeof(SuperClassID);
            FieldInfo fi = type
                .GetFields(BindingFlags.Static | BindingFlags.Public)
                .Where(f => f.FieldType == type && f.Name == sclassName).FirstOrDefault();
            return fi != null ? (SuperClassID)fi.GetValue(fi) : new SuperClassID();
        }

        public static SuperClassID GeometricObject = SClass_ID.Geomobject;
        public static SuperClassID ObjectModifier = SClass_ID.Osm;
        public static SuperClassID Material = SClass_ID.Material;
        public static SuperClassID Texture = SClass_ID.Texmap;
        public static SuperClassID ReferenceTarget = SClass_ID.RefTarget;
        public static SuperClassID ReferenceMaker = SClass_ID.RefMaker;
        public static SuperClassID Light = SClass_ID.Light;
        public static SuperClassID Shape = SClass_ID.Shape;
        public static SuperClassID Camera = SClass_ID.Camera;
        public static SuperClassID Helper = SClass_ID.Helper;
        public static SuperClassID Atmospheric = SClass_ID.Atmospheric;
        public static SuperClassID PositionController = SClass_ID.CtrlPosition;
        public static SuperClassID NotifyAll = new SuperClassID((SClass_ID)0xfffffff0);
        public static SuperClassID BaseNode = SClass_ID.Basenode;
        public static SuperClassID GenericDerivedObject = SClass_ID.GenDerivob;
        public static SuperClassID DerivedObject = SClass_ID.Derivob;
        public static SuperClassID ParameterBlock2 = SClass_ID.ParameterBlock2;

        public override string ToString() {
            return id.ToString();
        }

        public override bool Equals(object obj) {
            if ( !( obj is SuperClassID ) )
                return false;
            return ( (SuperClassID)obj ).id == id;
        }

        public override int GetHashCode() => id.GetHashCode();

        public static bool operator ==(SuperClassID x, SuperClassID y) { return x.id == y.id; }
        public static bool operator !=(SuperClassID x, SuperClassID y) { return x.id != y.id; }


        internal string GetIClassName(SuperClassID superClassID) {
            //get clas name from Max Enums
            string clsStr = Enum.GetName(typeof(SClass_ID), superClassID.id);
            return clsStr;
        }

        /// <summary>
        /// Return SuperClassID Name
        /// </summary>
        /// <param name="superClassID"></param>
        /// <returns></returns>
        public string GetClassName(SuperClassID superClassID) {
            //get Clas name From Kernel Struct
            Type type = typeof(SuperClassID);
            string className = type.GetFields(BindingFlags.Static | BindingFlags.Public)
                    .Where(f => f.FieldType == type && f.GetValue(null).ToString() == superClassID.ToString())
                    .Select(f => f.Name)
                    .FirstOrDefault();
            if ( className != null ) return className; 
            //if class not found in ClassID, provide original Max BuiltInClassIDA Name
             return GetIClassName(superClassID) + "- This Class is not Registed in SuperClassID. VIP.";
        }
    }
}
