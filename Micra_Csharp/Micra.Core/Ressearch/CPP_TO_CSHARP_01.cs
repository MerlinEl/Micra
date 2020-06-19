using Autodesk.Max;
using System;

namespace Micra.Core.Ressearch {
    public class CPP_TO_CSHARP_01 {
        private static IGlobal Glbl => GlobalInterface.Instance;  //note that global will be an instance of an abstract class.
        private static IInterface17 Intfc => Glbl.COREInterface17;
        private static int TimeNow => Glbl.COREInterface.Time;

        //C# Version
        public static IINode CreateBox() {
            IGenBoxObject boxObject = Kernel._Interface.CreateInstance(
                SClass_ID.Geomobject, 
                Kernel._Global.Class_ID.Create( (uint)BuiltInClassIDA.BOXOBJ_CLASS_ID,  0 )
            ) as IGenBoxObject;
            for (int i = 0; i < boxObject.NumParamBlocks; i++ ) {

                float outVal = 0;
                IInterval ivalid = new Interval()._IInterval;
                boxObject.ParamBlock.GetValue(i, Kernel.Now, ref outVal, ivalid);
                Max.Log("param:{0} val:{1} ivalid:{2}", boxObject.ParamBlock.GetType().Name, outVal, ivalid);
            }
            boxObject.SetParams(10, 10, 10, 1, 1, 1, true);
            var obj = Kernel._Interface.CreateObjectNode(boxObject);
            //INodeWrapper node = MaxNodeWrapper.Create(obj) as INodeWrapper;
            return obj;
        }

        //C# Version
        public static IINode CreateTeapot() {

            IClass_ID cid = Glbl.Class_ID.Create((uint)BuiltInClassIDA.TEAPOT_CLASS_ID, (uint)BuiltInClassIDB.TEAPOT_CLASS_ID);
            object obj = Intfc.CreateInstance(SClass_ID.Geomobject, cid as IClass_ID);
            if ( obj == null ) throw new Exception("Failed to create a sphere!");
            IINode n = Glbl.COREInterface.CreateObjectNode((IObject)obj);
            IObject iobj = (IObject)obj;
            IIParamArray ps = iobj.ParamBlock;
            /*Utility.GetClassPublicNames(ps.GetType()).ForEach(
                s => { Max.Log("\tPrimitive SceneObject:{0}", s); }
            );*/
            ps.SetValue(0, TimeNow, 20.0f);
            n.Move(Glbl.COREInterface.Time, Glbl.Matrix3.Create(), Glbl.Point3.Create(20, 20, 0), true, true, 0, true);
            return n;
        }

        /* C++ version
        INode* createPlane(float width, float length, int wsegs, int lsegs)
         {
 	        SimpleObject2* planeObj = (SimpleObject2*)GetCOREInterface()->CreateInstance(GEOMOBJECT_CLASS_ID,PLANE_CLASS_ID);
 	        if(planeObj)
 	        {
 		        INode* planeNode = GetCOREInterface()->CreateObjectNode(planeObj);
 		        if(!planeNode)
 		        {	
 			        planeObj->DeleteThis();
 			        return NULL;
 		        }
 		        IParamBlock2* pb = (IParamBlock2*)planeObj->GetReference(0);
 		        if(pb)
 		        {
 			        pb->SetValue(1,0,width);
 			        pb->SetValue(0,0,length);
 			        pb->SetValue(2,0,wsegs);
 			        pb->SetValue(3,0,lsegs);
 		        }
 		        return planeNode;
 	        }
 	        return NULL;
         }
        */

        // C# Version
        public static IINode CreatePlane(float width, float length, int wsegs, int lsegs) {
            IClass_ID obj = Glbl.Class_ID.Create((uint)BuiltInClassIDA.PLANE_CLASS_ID, (uint)BuiltInClassIDB.PLANE_CLASS_ID);
            if ( obj == null ) throw new Exception("Failed to create a plane!");
            IINode n = Glbl.COREInterface.CreateObjectNode((IObject)obj);
            if ( n == null ) {
                obj.Dispose();
                return null;
            }
            /*Max.Log("numParams:{0}", n.NumParamBlocks);
            for ( int i = 0; i < n.NumParamBlocks; i++ ) {

                IIParamBlock2 paramBlock2 = n.GetParamBlock(i);
                
                for (int j = 0; j < paramBlock2.NumParams; j++) {

                    Max.Log("param:{0}", paramBlock2.GetParamDefByIndex((uint)j));
                }
            }*/
            IObject iobj = (IObject)obj;
            IIParamArray ps = iobj.ParamBlock;
            /*Utility.GetClassPublicNames(ps.GetType()).ForEach(
                s => { Max.Log("\tPrimitive SceneObject:{0}", s); }
           );*/
            //ps.ToEnumerable().ForEach(p=> p.GetType())
            if ( ps != null ) {
                ps.SetValue(1, TimeNow, width);
                ps.SetValue(0, TimeNow, length);
                ps.SetValue(2, TimeNow, wsegs);
                ps.SetValue(3, TimeNow, lsegs);
            }
            return n;
        }

        /*  C++ version
        INode* CreateText(char* text, char* font, float size)	
           {
   	        SimpleSpline* splineObj = (SimpleSpline*)GetCOREInterface()->CreateInstance(SHAPE_CLASS_ID,Class_ID(TEXT_CLASS_ID,0));
   	        if(splineObj)
   	        {
   		        INode* textNode = GetCOREInterface()->CreateObjectNode(splineObj);
   		        if(!textNode)
   		        {	
   			        splineObj->DeleteThis();
   			        return NULL;
   		        }
   		
   		        ITextObject* textObj= GetTextObjectInterface(splineObj );
   		        if(textObj)
   		        {
   			        textObj->ChangeFont(font,0);
   			        textObj->ChangeText(text);
			        splineObj->GetParamBlock()->SetValue(TEXT_SIZE,0,size); // documentation is wrong this is the right way
   		        }
   		        splineObj->UpdateShape(0);
   		        return textNode;
   	        }
   	        return NULL;
           }
        */

        //C# Version
    }
}
