 TrackMouseCallBack::point_on_obj(ViewExp *vpt, IPoint2 m, Point3& pt, Point3 &norm)
(
 	// computes the normal ray at the point of intersection
 	Ray ray, world_ray;
 	float at, best_dist = 0.0f;
 	TimeValue t = MAXScript_time();	
 	Object *obj = NULL;
 	Matrix3 obtm, iobtm;
 	Point3 testNorm;
 
 	BOOL found_hit = FALSE;
 	
 	vl->face_num_val = vl->face_bary = &undefined;
 	hit_node = NULL;
 
 	// Calculate a ray from the mouse point
 	vpt->MapScreenToWorldRay(float(m.x), float(m.y), world_ray);
 
 	for( int i=(nodeTab.Count()-1); i>=0; i-- ) {
 		// Get the object from the node
 		INode* node = nodeTab[i];
 		ObjectState os = node->EvalWorldState(t);
 		obj = os.obj;	
 
 		// Back transform the ray into object space.
 		obtm	= node->GetObjectTM(t);
 		iobtm	= Inverse(obtm);
 		ray.p   = iobtm * world_ray.p;
 		ray.dir = VectorTransform(iobtm, world_ray.dir);
 		
 		// See if we hit the object
 		if (obj->IsSubClassOf(triObjectClassID))
 		{
 			TriObject*  tobj = (TriObject*)obj;
 			DWORD		fi;
 			Point3		bary;
 			if (tobj->mesh.IntersectRay(ray, at, testNorm, fi, bary)  &&
 			   ((!found_hit) || (at<=best_dist)) )
 			{
 				// Calculate the hit point and transform everything back into world space.
 				// record the face index and bary coord
 				best_dist = at;
 				pt = ray.p + ray.dir * at;
 				pt = pt * obtm;
 				norm = Normalize(VectorTransform(obtm, testNorm));
 				vl->face_num_val = Integer::intern(fi + 1);
 				vl->face_bary = new Point3Value(bary);
 				hit_node = node;
 				found_hit = TRUE;
 			}
 		}
 		else if (obj->IsSubClassOf(polyObjectClassID))
 		{
 			PolyObject* pobj = (PolyObject*)obj; 
 			int		fi;
 			//Point3		bary;
 			Tab<float> bary;
 			if (pobj->GetMesh().IntersectRay(ray, at, testNorm, fi, bary)  && ((!found_hit) || (at<=best_dist)) )
 			{
 				// Calculate the hit point and transform everything back into world space.
 				// record the face index and bary coord
 				best_dist = at;
 				pt = ray.p + ray.dir * at;
 				pt = pt * obtm;
 				norm = Normalize(VectorTransform(obtm, testNorm));
 				vl->face_num_val = Integer::intern(fi + 1);
 				//vl->face_bary = new Point3Value(bary);
 				hit_node = node;
 				found_hit = TRUE;
 			}
 		}
 		else if (obj->IntersectRay(t, ray, at, testNorm)  &&
 				((!found_hit) || (at<=best_dist)) )
 		{
 			// Calculate the hit point and transform everything back into world space.
 			best_dist = at;
 			pt = ray.p + ray.dir * at;
 			pt = pt * obtm;
 			norm = Normalize(VectorTransform(obtm, testNorm));
 			hit_node = node;
 			found_hit = TRUE;
 		}
 	}
 	if( found_hit ) return TRUE;
 
 	// Failed to find a hit on any node, look at the Normal Align Vector for the first node
 	if ((obj!=NULL) && obj->NormalAlignVector(t, pt, testNorm)) // See if a default NA vector is provided
 	{
 		pt   = pt * obtm;
 		norm = Normalize(VectorTransform(obtm, testNorm));
 		return TRUE;
 	}
 	else
 		return FALSE;
 }
 