using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Autodesk.Max;

namespace Micra.Tools {
    [Flags]
    enum ChannelPartID : uint {
        // The topology channel - the face or polygon structures. 
        TOPO_CHANNEL = 1 << 0,
        // The vertices of the object. 
        GEOM_CHANNEL = 1 << 1,
        // The texture vertices and procedural mappings. 
        TEXMAP_CHANNEL = 1 << 2,
        // This is no longer used. 
        MTL_CHANNEL = 1 << 3,
        // The sub-object selection channel. 
        SELECT_CHANNEL = 1 << 4,
        // The current level of selection. 
        SUBSEL_TYPE_CHANNEL = 1 << 5,
        // The miscellaneous bits controlling the item's display. 
        DISP_ATTRIB_CHANNEL = 1 << 6,
        // The color per vertex channel. 
        VERTCOLOR_CHANNEL = 1 << 7,
        // The used internally by 3ds Max for stripping. 
        GFX_DATA_CHANNEL = 1 << 8,
        // Displacement approximation. 
        DISP_APPROX_CHANNEL = 1 << 9,
        // The channel used by extension channel objects. 
        EXTENSION_CHANNEL = 1 << 13,
        // The ObjectState Transform that flows down the pipeline. 
        TM_CHANNEL = 1 << 10,
        // For internal use. 
        EDGEVISIBILITY_CHANNEL = 1 << 11,
        // For internal use. 
        DONT_RECREATE_TRISTRIP_CHANNEL = 1 << 12,
        // This is no longer used. 
        GLOBMTL_CHANNEL = (uint)1 << 31,
        OBJ_CHANNELS = TOPO_CHANNEL | GEOM_CHANNEL | SELECT_CHANNEL | TEXMAP_CHANNEL | MTL_CHANNEL | SUBSEL_TYPE_CHANNEL | DISP_ATTRIB_CHANNEL | VERTCOLOR_CHANNEL | GFX_DATA_CHANNEL | DISP_APPROX_CHANNEL | EXTENSION_CHANNEL,
        ALL_CHANNELS = (uint)OBJ_CHANNELS | (uint)TM_CHANNEL | (uint)GLOBMTL_CHANNEL
    }

    public class SurfaceRelax : Autodesk.Max.Plugins.OSModifier {

        public class SurfaceRelaxDescriptor : Autodesk.Max.Plugins.ClassDesc2 {

            IParamBlockDesc2 paramBlockDesc;
            public IParamBlockDesc2 ParamBlockDesc {

                get { return this.paramBlockDesc; }
            }

            IGlobal global;
            IClass_ID classID;

            public IGlobal Global {

                get { return this.global; }
            }

            public SurfaceRelaxDescriptor(IGlobal global_) {
                this.global = global_;

                this.classID = this.global.Class_ID.Create(0x43a73fbd, 0x4dcd0e93);

                this.paramBlockDesc = this.global.ParamBlockDesc2.Create(0,
                                                                          "Parameters",
                                                                          IntPtr.Zero,
                                                                          this,
                                                                          (ParamBlock2Flags)(
                                                                            (int)ParamBlock2Flags.Version +
                                                                            (int)ParamBlock2Flags.AutoConstruct +
                                                                            (int)ParamBlock2Flags.AutoUi
                                                                          ),
                                                                          new object[] { 1, 0 });
                // Add parameter and specify name, type, flags, control id, default, minimum, and maximum values
                this.paramBlockDesc.AddParam(0, new object[] { "Number", ParamType2.Float, ParamBlock2Flags.Animatable, 0, 0.5f, 0.0f, 1.0f });
            }

            public override string Category {

                get { return "Samples"; }
            }

            public override IClass_ID ClassID {

                get { return classID; }
            }

            public override string ClassName {

                get { return "SampleMod"; }
            }

            public override object Create(bool loading) {

                return new SurfaceRelax(this);
            }

            public override bool IsPublic {

                get { return true; }
            }

            public override SClass_ID SuperClassID {

                get { return SClass_ID.Osm; }
            }
        } //class SurfaqceRelaxDescriptor

        SurfaceRelaxDescriptor sdescriptor;
        IInterval validity;

        public SurfaceRelax(SurfaceRelaxDescriptor descriptor) : base() {

            this.sdescriptor = descriptor;
            this.validity = this.sdescriptor.Global.Interval.Create();
            this.validity.SetInfinite();
        }


        public override uint ChannelsChanged {

            get { return (uint)ChannelPartID.GEOM_CHANNEL; }
        }

        public override uint ChannelsUsed {

            get { return (uint)ChannelPartID.GEOM_CHANNEL; }
        }

        public override IClass_ID InputType {

            get { return sdescriptor.Global.DefObjectClassID; }
        }

        public override void ModifyObject(int t, IModContext mc, IObjectState os, IINode node) {

            return;
        }

        public override ICreateMouseCallBack CreateMouseCallBack {
            get { return null; }
        }

        public override RefResult NotifyRefChanged(IInterval changeInt, IReferenceTarget hTarget, ref UIntPtr partID, RefMessage message) {

            return RefResult.Succeed;
        }
    } //class SurfaceRelax

    public static class AssemblyFunctions {

        public static void AssemblyMain() {

            IGlobal g = Autodesk.Max.GlobalInterface.Instance;
            IInterface13 i = g.COREInterface13;
            i.AddClass(new SurfaceRelax.SurfaceRelaxDescriptor(g));
            //g.TheListener.EditStream.Wputs("It's ALIVE...");
            //g.TheListener.EditStream.Flush();
        }

        public static void AssemblyShutdown() {

        }
    }
}
