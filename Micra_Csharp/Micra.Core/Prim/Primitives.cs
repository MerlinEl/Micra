//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using Micra.Core.Extensions;
using Micra.Core.Utils;
using System;

namespace Micra.Core.Prim {

    /// <summary>
    /// Static container class containing all predefined primitives. 
    /// </summary>
    public static class Primitives {

        /// <summary> Create SceneObject by Primitive Name ( for now debug only )</summary>
        public static SceneObject CreateSceneObjectByPrimitiveName(string primObjName) {

            var pri = (PrimObjectFactory)ClassReader.GetFieldValueByName(typeof(Primitives), primObjName);
            if ( pri == null ) return null;
            return Animatable.CreatePluginInstance<SceneObject>(pri.SuperClassID, pri.ClassID);
        }

        #region Geometry object Factories
        // Standard
        public static PrimGeomObjectFactory Box = new PrimGeomObjectFactory(BuiltInClassIDA.BOXOBJ_CLASS_ID);
        public static PrimGeomObjectFactory Sphere = new PrimGeomObjectFactory(BuiltInClassIDA.SPHERE_CLASS_ID);
        public static PrimGeomObjectFactory Cylinder = new PrimGeomObjectFactory(BuiltInClassIDA.CYLINDER_CLASS_ID);
        public static PrimGeomObjectFactory Torus = new PrimGeomObjectFactory(BuiltInClassIDA.TAPEROSM_CLASS_ID); //BuiltInClassIDA.TORUS_CLASS_ID) //old
        public static PrimGeomObjectFactory Teapot = new PrimGeomObjectFactory(BuiltInClassIDA.TEAPOT_CLASS_ID, BuiltInClassIDB.TEAPOT_CLASS_ID);
        //public static PrimGeomObjectFactory TextPlus = new PrimGeomObjectFactory(BuiltInClassIDA.TEXT_CLASS_ID); // got crash
        public static PrimGeomObjectFactory Cone = new PrimGeomObjectFactory(BuiltInClassIDA.CONE_CLASS_ID);
        public static PrimGeomObjectFactory GeoSphere = new PrimGeomObjectFactory(BuiltInClassIDA.GSPHERE_CLASS_ID, BuiltInClassIDB.GSPHERE_CLASS_ID);
        public static PrimGeomObjectFactory Tube = new PrimGeomObjectFactory(BuiltInClassIDA.TUBE_CLASS_ID);
        public static PrimGeomObjectFactory Pyramid = new PrimGeomObjectFactory(BuiltInClassIDA.PYRAMID_CLASS_ID, BuiltInClassIDB.PYRAMID_CLASS_ID);
        public static PrimGeomObjectFactory Plane = new PrimGeomObjectFactory(BuiltInClassIDA.PLANE_CLASS_ID, BuiltInClassIDB.PLANE_CLASS_ID);
        // Extended
        public static PrimGeomObjectFactory Hedra = new PrimGeomObjectFactory(BuiltInClassIDA.HEDRA_CLASS_ID);
        //public static PrimGeomObjectFactory ChamferBox = new PrimGeomObjectFactory(); //not found
        //public static PrimGeomObjectFactory OilTank = new PrimGeomObjectFactory(); //not fount
        //public static PrimGeomObjectFactory Spindle	= 	new PrimGeomObjectFactory(); //not found
        //public static PrimGeomObjectFactory Gengon	= 	new PrimGeomObjectFactory(); //not found
        //public static PrimGeomObjectFactory Prism		= 	new PrimGeomObjectFactory(); //not found
        //public static PrimGeomObjectFactory RingWave	= 	new PrimGeomObjectFactory(); //not found
        //public static PrimGeomObjectFactory TorusKnot = 	new PrimGeomObjectFactory(); //not found
        //public static PrimGeomObjectFactory ChamferCyl = 	new PrimGeomObjectFactory(); //not found
        //public static PrimGeomObjectFactory Capsule = 	new PrimGeomObjectFactory(); //not found
        //public static PrimGeomObjectFactory L-Ext = 	new PrimGeomObjectFactory(); //not found
        //public static PrimGeomObjectFactory C-Ext = 	new PrimGeomObjectFactory(); //not found
        //public static PrimGeomObjectFactory Hose = 	new PrimGeomObjectFactory(); //not found
        // Got crash
        public static PrimGeomObjectFactory Wave = new PrimGeomObjectFactory(BuiltInClassIDA.WAVEOBJ_CLASS_ID);
        public static PrimGeomObjectFactory Donut = new PrimGeomObjectFactory(BuiltInClassIDA.DONUT_CLASS_ID);
        public static PrimGeomObjectFactory Loft = new PrimGeomObjectFactory(BuiltInClassIDA.LOFTOBJ_CLASS_ID);
        public static PrimGeomObjectFactory Pipe = new PrimGeomObjectFactory(BuiltInClassIDA.PIPE_CLASS_ID);
       
        #endregion

        #region Helper object Factories
        public static PrimHelperFactory PointHelper = new PrimHelperFactory(BuiltInClassIDA.POINTHELP_CLASS_ID);
        #endregion

        #region Modifier object factories
        public static PrimModObjectFactory Bend = new PrimModObjectFactory(BuiltInClassIDA.BENDOSM_CLASS_ID);
        public static PrimModObjectFactory Taper = new PrimModObjectFactory(BuiltInClassIDA.TAPEROSM_CLASS_ID);
        public static PrimModObjectFactory Twist = new PrimModObjectFactory(BuiltInClassIDA.TWISTOSM_CLASS_ID);
        public static PrimModObjectFactory Extrude = new PrimModObjectFactory(BuiltInClassIDA.EXTRUDEOSM_CLASS_ID);
        public static PrimModObjectFactory Smooth = new PrimModObjectFactory(BuiltInClassIDA.SMOOTHOSM_CLASS_ID);
        #endregion

        #region Shape object factories
        public static PrimShapeObjectFactory Circle = new PrimShapeObjectFactory(SClass_ID.Shape, BuiltInClassIDA.CIRCLE_CLASS_ID);
        public static PrimShapeObjectFactory Ellipse = new PrimShapeObjectFactory(SClass_ID.Shape, BuiltInClassIDA.ELLIPSE_CLASS_ID);
        public static PrimShapeObjectFactory Helix = new PrimShapeObjectFactory(SClass_ID.Shape, BuiltInClassIDA.HELIX_CLASS_ID);
        public static PrimShapeObjectFactory LinearShape = new PrimShapeObjectFactory(SClass_ID.Shape, BuiltInClassIDA.LINEARSHAPE_CLASS_ID);
        public static PrimShapeObjectFactory LinearWave = new PrimShapeObjectFactory(SClass_ID.Shape, BuiltInClassIDA.LINWAVE_CLASS_ID);
        public static PrimShapeObjectFactory Polygon = new PrimShapeObjectFactory(SClass_ID.Shape, BuiltInClassIDA.NGON_CLASS_ID);
        public static PrimShapeObjectFactory Rectangle = new PrimShapeObjectFactory(SClass_ID.Shape, BuiltInClassIDA.RECTANGLE_CLASS_ID);
        public static PrimShapeObjectFactory SineWave = new PrimShapeObjectFactory(SClass_ID.Shape, BuiltInClassIDA.SINEWAVE_CLASS_ID);
        #endregion 

        #region Camera object factories
        public static PrimCamObjectFactory SimpleCamera = new PrimCamObjectFactory(SClass_ID.Camera, BuiltInClassIDA.SIMPLE_CAM_CLASS_ID);
        public static PrimCamObjectFactory LookAtCamera = new PrimCamObjectFactory(SClass_ID.Camera, BuiltInClassIDA.LOOKAT_CAM_CLASS_ID);
        #endregion

        #region Light object factories
        public static PrimLightObjectFactory OmniLight = new PrimLightObjectFactory(SClass_ID.Light, BuiltInClassIDA.OMNI_LIGHT_CLASS_ID);
        public static PrimLightObjectFactory SpotLight = new PrimLightObjectFactory(SClass_ID.Light, BuiltInClassIDA.SPOT_LIGHT_CLASS_ID);
        public static PrimLightObjectFactory SunLight = new PrimLightObjectFactory(SClass_ID.Light, BuiltInClassIDA.SUNLIGHT_CLASS_ID);
        #endregion 

        #region Controller factories
        public static PrimCtrlObjectFactory LookAtCtrl = new PrimCtrlObjectFactory(SClass_ID.CtrlRotation, BuiltInClassIDA.LOOKAT_CONTROL_CLASS_ID);
        public static PrimCtrlObjectFactory Path = new PrimCtrlObjectFactory(SClass_ID.CtrlPosition, BuiltInClassIDA.PATH_CONTROL_CLASS_ID);
        #endregion
    }
}
