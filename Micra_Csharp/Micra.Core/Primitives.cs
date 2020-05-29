//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System;

namespace Micra.Core {
    /// <summary>
    /// The base class for predefined plug-in factories.
    /// </summary>
    public class PrimitiveFactory {
        protected SuperClassID scid;
        protected ClassID cid;
        public SuperClassID SuperClassID { get { return scid; } }
        public ClassID ClassID { get { return cid; } }
    }

    /// <summary>
    /// Base class for predefined plug-in factories. Introduces a Create function for creating the primitive in the scene 
    /// with a new node. 
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public abstract class PrimitiveFactory<T> : PrimitiveFactory {
        internal PrimitiveFactory(SClass_ID scid, BuiltInClassIDA cidA, BuiltInClassIDB cidB) { this.scid = scid; this.cid = new ClassID((uint)cidA, (uint)cidB); }
        internal PrimitiveFactory(SClass_ID scid, BuiltInClassIDA cidA) { this.scid = scid; this.cid = new ClassID((uint)cidA, 0); }

        /// <summary>
        /// Creates a primitive with a new node.
        /// </summary>
        /// <returns></returns>
        public abstract T Create();
    }

    /// <summary>
    /// Base class for predefined sceene object factories. 
    /// </summary>
    public class PrimObjectFactory : PrimitiveFactory<SceneObject> {
        public PrimObjectFactory(SClass_ID scid, BuiltInClassIDA cidA, BuiltInClassIDB cidB) : base(scid, cidA, cidB) { }
        public PrimObjectFactory(SClass_ID scid, BuiltInClassIDA cidA) : base(scid, cidA) { }

        public override SceneObject Create() {
            SceneObject o = Animatable.CreatePluginInstance<SceneObject>(scid, cid);
            Node n = Node.Create(o);
            if ( n == null )
                throw new Exception("Failed to create object node");
            o.Node = n;
            Kernel.RedrawViews();
            return o;
        }
    }

    /// <summary>
    /// Base class for predefined geometric object factories.
    /// </summary>
    public class PrimGeomObjectFactory : PrimObjectFactory {
        public PrimGeomObjectFactory(BuiltInClassIDA cidA, BuiltInClassIDB cidB) : base(SClass_ID.Geomobject, cidA, cidB) { }
        public PrimGeomObjectFactory(BuiltInClassIDA cidA) : base(SClass_ID.Geomobject, cidA) { }
    }

    /// <summary>
    /// Base class for predefined geometric object factories.
    /// </summary>
    public class PrimHelperFactory : PrimObjectFactory {
        public PrimHelperFactory(BuiltInClassIDA cidA, BuiltInClassIDB cidB) : base(SClass_ID.Helper, cidA, cidB) { }
        public PrimHelperFactory(BuiltInClassIDA cidA) : base(SClass_ID.Helper, cidA) { }
    }

    /// <summary>
    /// Base class for predefined modifier factories.
    /// </summary>
    public class PrimModObjectFactory : PrimitiveFactory<Modifier> {
        public PrimModObjectFactory(BuiltInClassIDA cidA, BuiltInClassIDB cidB) : base(SClass_ID.Osm, cidA, cidB) { }
        public PrimModObjectFactory(BuiltInClassIDA cidA) : base(SClass_ID.Osm, cidA) { }

        public override Modifier Create() {
            return Animatable.CreatePluginInstance<Modifier>(scid, cid);
        }

        public Modifier Create(Node node) {
            Modifier m = Create();
            m.Apply(node);
            return m;
        }
    }

    /// <summary>
    /// Static container class containing all predefined primitives. 
    /// </summary>
    public static class Primitives {
        #region primitive geometric object factories
        public static PrimGeomObjectFactory Teapot = new PrimGeomObjectFactory(BuiltInClassIDA.TEAPOT_CLASS_ID, BuiltInClassIDB.TEAPOT_CLASS_ID);
        public static PrimGeomObjectFactory Box = new PrimGeomObjectFactory(BuiltInClassIDA.BOXOBJ_CLASS_ID);
        public static PrimGeomObjectFactory Sphere = new PrimGeomObjectFactory(BuiltInClassIDA.SPHERE_CLASS_ID);
        public static PrimGeomObjectFactory Cylinder = new PrimGeomObjectFactory(BuiltInClassIDA.CYLINDER_CLASS_ID);
        public static PrimGeomObjectFactory Wave = new PrimGeomObjectFactory(BuiltInClassIDA.WAVEOBJ_CLASS_ID);
        public static PrimGeomObjectFactory Torus = new PrimGeomObjectFactory(BuiltInClassIDA.TORUS_CLASS_ID);
        public static PrimGeomObjectFactory Donut = new PrimGeomObjectFactory(BuiltInClassIDA.DONUT_CLASS_ID);
        public static PrimGeomObjectFactory GSphere = new PrimGeomObjectFactory(BuiltInClassIDA.GSPHERE_CLASS_ID);
        public static PrimGeomObjectFactory Hedra = new PrimGeomObjectFactory(BuiltInClassIDA.HEDRA_CLASS_ID);
        public static PrimGeomObjectFactory Loft = new PrimGeomObjectFactory(BuiltInClassIDA.LOFTOBJ_CLASS_ID);
        public static PrimGeomObjectFactory Pipe = new PrimGeomObjectFactory(BuiltInClassIDA.PIPE_CLASS_ID);
        public static PrimGeomObjectFactory Pyramid = new PrimGeomObjectFactory(BuiltInClassIDA.PYRAMID_CLASS_ID);
        public static PrimGeomObjectFactory Tube = new PrimGeomObjectFactory(BuiltInClassIDA.TUBE_CLASS_ID);
        #endregion

        #region Primitive Helper Object Factories
        public static PrimHelperFactory PointHelper = new PrimHelperFactory(BuiltInClassIDA.POINTHELP_CLASS_ID);
        #endregion

        #region primitive modifier object factories
        public static PrimModObjectFactory Bend = new PrimModObjectFactory(BuiltInClassIDA.BENDOSM_CLASS_ID);
        public static PrimModObjectFactory Taper = new PrimModObjectFactory(BuiltInClassIDA.TAPEROSM_CLASS_ID);
        public static PrimModObjectFactory Twist = new PrimModObjectFactory(BuiltInClassIDA.TWISTOSM_CLASS_ID);
        public static PrimModObjectFactory Extrude = new PrimModObjectFactory(BuiltInClassIDA.EXTRUDEOSM_CLASS_ID);
        public static PrimModObjectFactory Smooth = new PrimModObjectFactory(BuiltInClassIDA.SMOOTHOSM_CLASS_ID);
        #endregion

        #region shape object factories
        public static PrimObjectFactory Circle = new PrimObjectFactory(SClass_ID.Shape, BuiltInClassIDA.CIRCLE_CLASS_ID);
        public static PrimObjectFactory Ellipse = new PrimObjectFactory(SClass_ID.Shape, BuiltInClassIDA.ELLIPSE_CLASS_ID);
        public static PrimObjectFactory Helix = new PrimObjectFactory(SClass_ID.Shape, BuiltInClassIDA.HELIX_CLASS_ID);
        public static PrimObjectFactory LinearShape = new PrimObjectFactory(SClass_ID.Shape, BuiltInClassIDA.LINEARSHAPE_CLASS_ID);
        public static PrimObjectFactory LinearWave = new PrimObjectFactory(SClass_ID.Shape, BuiltInClassIDA.LINWAVE_CLASS_ID);
        public static PrimObjectFactory Polygon = new PrimObjectFactory(SClass_ID.Shape, BuiltInClassIDA.NGON_CLASS_ID);
        public static PrimObjectFactory Plane = new PrimObjectFactory(SClass_ID.Shape, BuiltInClassIDA.PLANE_CLASS_ID);
        public static PrimObjectFactory Rectangle = new PrimObjectFactory(SClass_ID.Shape, BuiltInClassIDA.RECTANGLE_CLASS_ID);
        public static PrimObjectFactory SineWave = new PrimObjectFactory(SClass_ID.Shape, BuiltInClassIDA.SINEWAVE_CLASS_ID);
        #endregion 

        #region camera object factories
        public static PrimObjectFactory SimpleCamera = new PrimObjectFactory(SClass_ID.Camera, BuiltInClassIDA.SIMPLE_CAM_CLASS_ID);
        public static PrimObjectFactory LookAtCamera = new PrimObjectFactory(SClass_ID.Camera, BuiltInClassIDA.LOOKAT_CAM_CLASS_ID);
        #endregion

        #region light object factories
        public static PrimObjectFactory OmniLight = new PrimObjectFactory(SClass_ID.Light, BuiltInClassIDA.OMNI_LIGHT_CLASS_ID);
        public static PrimObjectFactory SpotLight = new PrimObjectFactory(SClass_ID.Light, BuiltInClassIDA.SPOT_LIGHT_CLASS_ID);
        public static PrimObjectFactory SunLight = new PrimObjectFactory(SClass_ID.Light, BuiltInClassIDA.SUNLIGHT_CLASS_ID);
        #endregion 

        #region controller factories
        public static PrimObjectFactory LookAtCtrl = new PrimObjectFactory(SClass_ID.CtrlRotation, BuiltInClassIDA.LOOKAT_CONTROL_CLASS_ID);
        public static PrimObjectFactory Path = new PrimObjectFactory(SClass_ID.CtrlPosition, BuiltInClassIDA.PATH_CONTROL_CLASS_ID);
        #endregion
    }
}
