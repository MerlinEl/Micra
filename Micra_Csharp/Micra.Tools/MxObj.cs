using Autodesk.Max;
using System;
using System.Collections.Generic;

namespace Micra.Tools {
    internal class MxObj {

        internal static IINode GetFirstSelectedNode() {
            return MxGet.Interface.GetSelNode(0);
        }
        /// <summary>
        /// Get All Scene Objects
        /// </summary>
        internal static List<IINode> Objects() { //OK

            IINode root_node = MxGet.Interface.RootNode;
            List<IINode> node_list = new List<IINode>() { };
            for ( int i = 1; i < root_node.NumChildren; i++ ) {

                IINode child_node = MxGet.Interface.RootNode.GetChildNode(i);
                node_list.Add(child_node);
            };
            return node_list;
        }

        internal static List<IINode> GetSelectedNodes() {

            
            IINodeTab selNodes = null;
            MxSet.LogLi("GetSelectedNodes");
            MxGet.Interface.GetSelNodeTab(selNodes);
            MxSet.LogLi("GetSelectedNodes" + selNodes);
            MxSet.LogLi("GetSelectedNodes" + selNodes.Count.ToString());
            List<IINode> node_list = new List<IINode>() { };
            for ( int i = 0; i < selNodes.Count; i++ ) {
                MxSet.LogLi("\t\n" + selNodes[i]);
                node_list.Add(selNodes[i]);
            }
            return node_list;
        }

        internal static String GetNodeName(uint handle) {

            //MxGet.Interface.SelectNode(node);
            IINode theNode = MxGet.Interface.GetINodeByHandle(handle);
            return theNode.Name;
        }


        /// This method is used to build a mesh with the data contained in the class. 
        /// It will ususally will be called when the object is rebuilt during deserialization ///
        /// got guidance from here : http://eliang.blogspot.com/2011/10/creating-triangle-mesh-with-3ds-max-sdk.html        
        /*private ITriObject BuildMesh(bool build_normals = true, bool build_maps = true) {          // Make a new TriObject class         
            ITriObject triobj = Kernel.Global.TriObject.Create();         // bail if null         
            if ( triobj == null ) return null;          // grab the IMesh instance in the TriObject         
            IMesh mesh = triobj.Mesh;         // bail if null         if (triobj == null)                 
            return null;
            int numVertices = this.Verts.Count;
            int numTriangles = this.Faces.Count;
            int numNormals = this.Normals.Count;
            int numMaps = this.Maps.Count;          // set vertex array size in the mesh         
            mesh.SetNumVerts(numVertices, false, true);         // set triangle array size in the mesh         
            mesh.SetNumFaces(numTriangles, false, true);          // Loop and set vertex positions         
            for ( int i = 0; i < numVertices; i++ )
                mesh.SetVert(i, this.Verts[i].Position.ToIPoint3());          // Loop and set the basic face data         
            for ( int i = 0, j = 0; i < numTriangles; i++, j += 3 ) {
                int v0 = (int)this.Faces[i].Verts[0];
                int v1 = (int)this.Faces[i].Verts[1];
                int v2 = (int)this.Faces[i].Verts[2];                  // vertex positions                 
                IFace face = mesh.Faces[i];
                face.MatID = 1;
                face.SetEdgeVisFlags(this.Faces[i].EdgeVis[0], this.Faces[i].EdgeVis[1], this.Faces[i].EdgeVis[2]);
                face.SetVerts(v0, v1, v2);                  // set the fac smoothing group if there was one set.                
                if ( this.Faces[i].SmoothingGroup != -1 ) {
                    face.SmGroup = (uint)this.Faces[i].SmoothingGroup;
                }
            }          // build uv information using the maps of the mesh         
            if ( build_maps == true ) {                 // initialize the map array to the needed size                
                mesh.SetNumMaps(numMaps, false);                  // start at 1 as zero is Vert color.. i think.                 
                for ( int m = 1; m < numMaps; m++ ) {                         // enable map support                         
                    mesh.SetMapSupport(m, true);  // enable map channel                          // get the current IMeshMap iteration                         
                    IMeshMap map = mesh.Maps[m];                          // set num of verts to the vert count of the map List<>                         
                    int numMapVerts = this.Maps[m].TVerts.Count;
                    mesh.SetNumMapVerts(m, numMapVerts, false);
                    for ( int i = 0; i < numMapVerts; i++ ) {
                        mesh.SetMapVert(m, i, ( this.Maps[m].TVerts[i] ).ToIPoint3());
                    }                           // set num of verts to the face count of the map List<>                         
                    int numMapFaces = this.Maps[m].TFaces.Count;
                    mesh.SetNumMapFaces(m, numMapFaces, false, 0);                          // grab the now intitialzed list of faces                         
                    IList mapFaces = mesh.MapFaces(m);                          // loop and associate vertecies by the stored indecies.                         
                    for ( int i = 0; i < numMapFaces; i++ ) {
                        ITVFace tFace = mapFaces[i];
                        int v0 = (int)this.Maps[m].TFaces[i].Verts[0];
                        int v1 = (int)this.Maps[m].TFaces[i].Verts[1];
                        int v2 = (int)this.Maps[m].TFaces[i].Verts[2];
                        tFace.SetTVerts(v0, v1, v2);
                    }
                }
            }          // build normal information for each vert and face association         
            if ( build_normals == true ) {                 // call this to initialize the normal arrays                 
                mesh.BuildNormals();                  // tell the mesh we will be specifying normals                 
                mesh.SpecifyNormals();                  // class to aid normal updating                 
                IMeshNormalSpec normalSpec = mesh.SpecifiedNormals;                                  // clear any pre calculated normals                 
                normalSpec.ClearNormals();                  // set the normal vertex array size                 
                normalSpec.SetNumNormals(numVertices);                  // loop and set vertex normals                 
                for ( int i = 0; i < numVertices; i++ ) {
                    IPoint3 ip3 = ( this.Normals[i].Direction.ToIPoint3() ).Normalize;
                    normalSpec.NormalArray.Set(ip3.X, ip3.Y, ip3.Z);
                    normalSpec.SetNormalExplicit(i, false);
                }                  // set normal face array size                 
                normalSpec.SetNumFaces(numTriangles);
                for ( int i = 0, j = 0; i < numTriangles; i++, j += 3 ) {
                    int v0 = (int)this.Faces[i].Verts[0];
                    int v1 = (int)this.Faces[i].Verts[1];
                    int v2 = (int)this.Faces[i].Verts[2];                          // vertex positions                         
                    IFace face = mesh.Faces[i];                          // vertex normals                         
                    IMeshNormalFace normalFace = normalSpec.Face(i);
                    normalSpec.SetNormal(i, v0, ( this.Normals[v0].Direction.ToIPoint3() ).Normalize);
                    normalSpec.SetNormal(i, v1, ( this.Normals[v1].Direction.ToIPoint3() ).Normalize);
                    normalSpec.SetNormal(i, v2, ( this.Normals[v2].Direction.ToIPoint3() ).Normalize);
                    normalFace.SpecifyAll(true);
                    //normalFace.SetNormalID(0, v0);                         
                    //normalFace.SetNormalID(1, v1);                         
                    //normalFace.SetNormalID(2, v2);                         
                    normalFace.SetSpecified(0, true);
                    normalFace.SetSpecified(1, true);
                    normalFace.SetSpecified(2, true);
                }
            }          // tell the mesh to rebuild its internal cache's... like a recompute.         
            mesh.InvalidateGeomCache();
            mesh.InvalidateTopologyCache();
            return triobj;
        }*/


        ///Function that populates necassary mesh data to this class, from scene data. Called before serialization. 
        ///
        ///The IINode, containing the mesh, to be serialized 
        /*public void Populate(IINode node) {         // make sure the node is valid         
            if ( node == null ) return;          // get the object ref as a tri object         
            ITriObject triObj = MxsSharp.MeshOps.GetITriObject(node);         // bail if we failed to retrieve         
            if ( triObj == null ) return;                  // get the mesh/IMesh from the tri object         
            IMesh mesh = triObj.Mesh;         // bail if we failed to retrieve         
            if ( mesh == null ) return;          // initialize the base data variables          
            this.Verts = new List();
            this.Faces = new List();
            this.Normals = new List();
            this.Name = node.Name;          // serialize the transform        
            this.Transform = new Matrix();
            this.Transform.Populate(node);          // create serialized data for mesh vertex         
            int count = 0;
            foreach ( IPoint3 vPos in mesh.Verts ) {                             // Create custom Vertex class that can be serialized                 
                Vertex vrt = new Vertex();                 // Populate the vertex class with data - cannot do this on itilialize due to serialization                 
                vrt.Populate(vPos);                 // Add to this class' Verts list                 
                this.Verts.Add(vrt);
                count++;
            }          // create serialized data for mesh faces         
            foreach ( IFace iface in mesh.Faces ) {                 // Create custom Face class that can be serialized                 
                Face face = new Face();                 // Populate the Face class with data - cannot do this on itilialize due to serialization                 
                face.Populate(iface);                 // Add to this class' Faces list                 
                this.Faces.Add(face);
            }          // Serialize any map channels the mesh may have.. uvs and such         
            if ( mesh.NumMaps > 0 ) {
                this.Maps = new List();
                for ( int mi = 0; mi < mesh.NumMaps; mi++ ) {                         // Create custom MeshMap class that can be serialized                         
                    MeshMap map = new MeshMap();                         // Populate the MeshMap class with data - cannot do this on itilialize due to serialization                         
                    map.Populate(mesh, mi);                         // Add to this class' Maps list                         
                    this.Maps.Add(map);
                }
            }          // build / check normals before we serialize them. otherwise we may not have any normals.         
            mesh.BuildNormals(); mesh.BuildRenderNormals();                  // create serialized data for mesh normals         
            for ( int i = 0; i < mesh.NormalCount; i++ ) {                     // Create custom Normal class that can be serialized                             
                IPoint3 inml = mesh.GetNormal(i);
                Normal normal = new Normal();                 // Populate the Normal class with data - cannot do this on itilialize due to serialization                 
                normal.Populate(inml);                 // Add to this class' Normals list                 
                this.Normals.Add(normal);
            }
            mesh.DisplayNormals(1, 3.0f);
        }*/


        /*public static String GetTriMeshFromNode(uint handle) {
            int t = 0;
            IGlobal Global = Autodesk.Max.GlobalInterface.Instance;
            IINode node = Global.COREInterface13.GetINodeByHandle(handle);

            IObject obj = node.EvalWorldState(0, true).Obj;

            if ( node.ObjectRef.SuperClassID != SClass_ID.Geomobject ) return ( "SuperClass : " + node.ObjectRef.SuperClassID.ToString() + " not valid" );

            IMesh mesh = obj.ConvertToType(t, IClass_ID ? !? !? !? !?);

            return mesh.GetVert(0).ToString();
        }*/

        internal static void getChildNodesRecurse(IINode node, List<IINode> array) {

            array.Add(node);
            for ( int i = 0; i < node.NumChildren; i++ ) {
                getChildNodesRecurse(node.GetChildNode(i), array);
            }
        }

        /*internal static List<IINode> getSceneNodesList() {
            // make a list to fill

            List<IINode> nodeList = new List<IINode>();
            // loop from the scene 'Root' node
            for ( int i = 0; i < this._interface.RootNode.NumChildren; i++ ) {
                // call recusrive function and populate list with all nodes
                this.getChildNodesRecurse(this._interface.RootNode.GetChildNode(i), nodeList);
            }

            return nodeList;
        }

        internal static List<IINode> GetSelectedNodes() {
            // make a list to fill
            List<IINode> selectionList = new List<IINode>();
            // for all the nodes in the scene
            foreach ( IINode node in ( this.getSceneNodesList() ) ) {
                // if it's selected
                if ( node.Selected == true ) {
                    // add it to the return list
                    selectionList.Add(node);
                }
            }
            return selectionList;
        }*/
    }
}


/*
  public void EnumControl(IControl cntrl)
        {
            
            // print the name of this control
            this.PrintToListener(cntrl.ClassName);

            // make an object type to be passed to the getvalue
            object val = null;

            // make an interval class and set it to forever
            IInterval interval = _global.Interval.Create();
            interval.SetInfinite();

            // A switch/case to test the super class id of the control
            switch (cntrl.SuperClassID)
            {
                case SClass_ID.CtrlInteger:
                    // make a local var of the type this super class requires
                    int _val_Int = 0;

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type                            
                    val = _val_Int as object;

                    // populates val with the value.                                                             
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_Int = (int)val;

                    this.PrintToListener("--> " + _val_Int.ToString());
                    break;
                case SClass_ID.CtrlFloat:
                    // make a local var of the type this super class requires
                    float _val_Flt = 0.0f;

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type                                                        
                    val = _val_Flt as object;

                    // populates val with the value.                   
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_Flt = (float)val;

                    this.PrintToListener("--> " + _val_Flt.ToString());

                    break;
                case SClass_ID.CtrlPoint3:
                    // make a local var of the type this super class requires
                    IPoint3 _val_p3 = this._global.Point3.Create(0.0, 0.0, 0.0);

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type                                                                                    
                    val = _val_p3 as object;

                    // populates val with the value.                   
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_p3 = (IPoint3)val;

                    this.PrintToListener("--> " + _val_p3.ToString());

                    break;
                case SClass_ID.CtrlPosition:

                    // make a local var of the type this super class requires
                    IMatrix3 _val_tm = this._global.Matrix3.Create();

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type
                    val = _val_tm as object;

                    // populates val with the value.                 
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_tm = (IMatrix3)val;

                    // print
                    this.PrintToListener("--> " + _val_tm.Trans.X.ToString() + ", " + _val_tm.Trans.Y.ToString() + ", " + _val_tm.Trans.Z.ToString());

                    break;

                case SClass_ID.CtrlMatrix3:
                    // make a local var of the type this super class requires
                    _val_tm = this._global.Matrix3.Create();

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type
                    val = _val_tm as object;

                    // populates val with the value.                 
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_tm = (IMatrix3)val;

                    // print
                    this.PrintToListener("--> " + _val_tm.Trans.X.ToString() + ", " + _val_tm.Trans.Y.ToString() + ", " + _val_tm.Trans.Z.ToString());

                    break;
                case SClass_ID.CtrlQuat:
                    // make a local var of the type this super class requires
                    IQuat _val_q = this._global.Quat.Create();

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type
                    val = _val_q as object;

                    // populates val with the value.                 
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_q = (IQuat)val;

                    IntPtr x = new IntPtr(), y = new IntPtr(), z = new IntPtr();
                    _val_q.GetEuler(x, y, z);

                    

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    this.PrintToListener("--> [" + _val_q.Vector.X.ToString() + ", " + _val_q.Vector.Y.ToString() + ", " + _val_q.Vector.Z.ToString() + "]");

                    break;
                case SClass_ID.CtrlRotation:
                    // make a local var of the type this super class requires
                    _val_q = this._global.Quat.Create();

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type
                    val = _val_q as object;

                    // populates val with the value.                 
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_q = (IQuat)val;

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    this.PrintToListener("--> [" + _val_q.Vector.X.ToString() + ", " + _val_q.Vector.Y.ToString() + ", " + _val_q.Vector.Z.ToString() + "]");

                    break;
                case SClass_ID.CtrlScale:
                    // make a local var of the type this super class requires
                    IScaleValue _val_sv = this._global.ScaleValue.Create();

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type
                    val = _val_sv as object;

                    // populates val with the value.                 
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_sv = (IScaleValue)val;

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    this.PrintToListener("--> " + _val_sv.S.ToString());

                    break;
                default:
                    //default stuff
                    break;
            }

            // now loop any child sub anims, convert to control and recurse
            int numsubs = cntrl.NumSubs;
            for (int i = 0; i < numsubs; ++i)
            {
                IAnimatable anim = cntrl.SubAnim(i);
                if (anim == null)
                    continue;
                
                IControl subcntrl = (IControl)anim.GetInterface(InterfaceID.Control); // do we have a control (theres no single superclass id for controls)

                if (subcntrl != null)
                {

                    this.EnumControl(subcntrl);
                }
            }
        }
*/
