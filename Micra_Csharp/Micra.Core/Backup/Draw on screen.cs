﻿//https://getcoreinterface.typepad.com/blog/c/


Quite simple, right? A bunch of points and some calls to draw lines.
Well ... easy things get complicated very fast when you draw something custom and parametric.
Now we can start by creating a method responsible for drawing a double arrowhead segment with a label in the center of the segment:

void Informix::drawMyArrows(Point3 p1, Point3 p2, const wchar_t* my_text, ViewExp* vpt)
{
    float arrow_scale_factor = 0.05;
    float arrow_wing_factor = 10.0f; // max(max(p1.z + p2.z, p1.x + p2.x)*arrow_scale_factor, 1);
    pblock2->GetValue(pb_wing_spin, GetCOREInterface()->GetTime(), arrow_wing_factor, FOREVER);
    Point3 wing_side_point(0,0,0);
    Point3 wing_other_side_point(0,0,0);
    Point3 ref_point((p1.x + p2.x), (p1.y + p2.y), (p1.z + p2.z));
    Point3 midpoint = ref_point / 2;

    //prepare point for left arrow
    Point3 left_reference_point = p1*(1-arrow_scale_factor)+p2*arrow_scale_factor;
    makeWingsidePoints(left_reference_point, wing_side_point, wing_other_side_point, arrow_wing_factor, p1);
    Point3 my_gizmo_point_left[5] = { p2, p1, wing_side_point, p1, wing_other_side_point };

    //prepare point for right arrow
    Point3 right_reference_point = p1*arrow_scale_factor + p2*(1 - arrow_scale_factor);
    makeWingsidePoints(right_reference_point, wing_side_point, wing_other_side_point, arrow_wing_factor, p1);
    Point3 my_gizmo_point_right[5] = { p1, p2, wing_side_point, p2, wing_other_side_point };

    //draw points and labels
    GraphicsWindow *gw = vpt->getGW();
    DrawLineProc lp(gw);
    lp.SetLineColor(0, 0, 0);
    lp.proc(my_gizmo_point_left, 5);
    lp.proc(my_gizmo_point_right, 5);
    gw->setColor(TEXT_COLOR, 0, 0, 0);
    gw->text(&midpoint, my_text);

}

Now we can organize some repetitive code into a helper method:

void Informix::makeWingsidePoints(  Point3 reference_point, 
                                    Point3 &wing_side_point, 
                                    Point3 &wing_other_side_point, 
                                    float arrow_wing_factor, 
                                    const Point3 source)
{
        wing_side_point = reference_point;
        wing_other_side_point = wing_side_point;

        if(reference_point.x != source.x)
        {
            wing_side_point.z -= arrow_wing_factor;
            wing_other_side_point.z += arrow_wing_factor;
        }
        else
        {
            wing_side_point.x -= arrow_wing_factor;
            wing_other_side_point.x += arrow_wing_factor;
        }
        wing_side_point.y -= arrow_wing_factor;
        wing_other_side_point.y += arrow_wing_factor;
}

Now our updated Modifier::Display() method is easier to read:

int Informix::Display(TimeValue t, INode* inode, ViewExp* vpt, int flagst, ModContext* mc)
{
    TimeValue current_time = GetCOREInterface()->GetTime();
    Box3 bounding_box;
    inode->EvalWorldState(current_time).obj->GetLocalBoundBox(current_time, inode,vpt,bounding_box);
    Point3 min = bounding_box.Min();
    Point3 max = bounding_box.Max();
    Point3 x_max(max.x, min.y, min.z);
    Point3 y_max(min.x, max.y, min.z);
    Point3 z_max(min.x, min.y, max.z);

    std::wstring label_x = std::to_wstring(max.x - min.x) + L" units";
    std::wstring label_y = std::to_wstring(max.y - min.y) + L" units";
    std::wstring label_z = std::to_wstring(max.z - min.z) + L" units";

    drawMyArrows(min, x_max, label_x.c_str(), vpt);
    drawMyArrows(min, y_max, label_y.c_str(), vpt);
    drawMyArrows(min, z_max, label_z.c_str(), vpt);

    return 0;
}

Basically this is it.
Having this coded in a simple combination, we end up having the following result when applying our modifier to an object: