using Autodesk.Max;
using System;

namespace Micra.Core.Prim {

    public class PrimitiveTypes {

        /// <summary> Get Primitive type  ( for now debug only )
        ///     <example> 
        ///         <code>
        ///             example: 
        ///             <br>string categoryType = CbxPrimitiveCategories.SelectedItem.ToString();</br>
        ///             <br>Type primType = GetPrimitiveTypeByName(categoryType);</br>
        ///             <br>var items = ClassReader.GetClassNames(typeof(Primitives), primType).ToArray();</br>
        ///             <br>LbxPrimitiveObjectNames.Items.AddRange(items);</br>
        ///         </code>
        ///     </example>
        ///     <para>param: <paramref name=""/></para>
        /// </summary>
        public static Type GetPrimitiveTypeByName(string typeName) {

            return Switch.On(typeName)
            .Case("Geometry").Then(typeof(PrimGeomObjectFactory))
            .Case("Shapes").Then(typeof(PrimShapeObjectFactory))
            .Case("Helpers").Then(typeof(PrimHelperFactory))
            .Case("Cameras").Then(typeof(PrimCamObjectFactory))
            .Case("Lights").Then(typeof(PrimLightObjectFactory))
            .Default(null);
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
    /// Base class for predefined shapes object factories.
    /// </summary>
    public class PrimShapeObjectFactory : PrimObjectFactory {
        public PrimShapeObjectFactory(SClass_ID scid, BuiltInClassIDA cidA, BuiltInClassIDB cidB) : base(scid, cidA, cidB) { }
        public PrimShapeObjectFactory(SClass_ID scid, BuiltInClassIDA cidA) : base(scid, cidA) { }
    }

    /// <summary>
    /// Base class for predefined helpers object factories.
    /// </summary>
    public class PrimHelperFactory : PrimObjectFactory {
        public PrimHelperFactory(BuiltInClassIDA cidA, BuiltInClassIDB cidB) : base(SClass_ID.Helper, cidA, cidB) { }
        public PrimHelperFactory(BuiltInClassIDA cidA) : base(SClass_ID.Helper, cidA) { }
    }

    /// <summary>
    /// Base class for predefined cameras object factories.
    /// </summary>
    public class PrimCamObjectFactory : PrimObjectFactory {
        public PrimCamObjectFactory(SClass_ID scid, BuiltInClassIDA cidA, BuiltInClassIDB cidB) : base(scid, cidA, cidB) { }
        public PrimCamObjectFactory(SClass_ID scid, BuiltInClassIDA cidA) : base(scid, cidA) { }
    }

    /// <summary>
    /// Base class for predefined lights object factories.
    /// </summary>
    public class PrimLightObjectFactory : PrimObjectFactory {
        public PrimLightObjectFactory(SClass_ID scid, BuiltInClassIDA cidA, BuiltInClassIDB cidB) : base(scid, cidA, cidB) { }
        public PrimLightObjectFactory(SClass_ID scid, BuiltInClassIDA cidA) : base(scid, cidA) { }
    }

    /// <summary>
    /// Base class for predefined controll object factories.
    /// </summary>
    public class PrimCtrlObjectFactory : PrimObjectFactory {
        public PrimCtrlObjectFactory(SClass_ID scid, BuiltInClassIDA cidA, BuiltInClassIDB cidB) : base(scid, cidA, cidB) { }
        public PrimCtrlObjectFactory(SClass_ID scid, BuiltInClassIDA cidA) : base(scid, cidA) { }
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
}
