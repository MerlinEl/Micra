/*
created		2015-05-21
modified	2016-05-11
Author: Nikolay Litvinov
There is no need to take care in the modifer UnwrapUVW to disable IgnoreBackFaceCull.
And automatically enable UV Editor
1)Assigns unwrap UVW
2)Disables IgnoreBackFaceCull off
3)Entry in the UV Editor
4)Set subobjectLevel = polygons
5)Enables Freeform Mode transformations

*/
macroScript UnwrapUVW_Editor_AutOOpen
	Category:"Niklit Scripts"
	Tooltip:"UnwrapUVW Editor AutOOpen"
(
global gco
fn gco_fn = (gco=modPanel.getCurrentObject())
fn FN_Unwrap_Editor=(
gco_fn()
gco.setIgnoreBackFaceCull off
gco.edit()
gco.unwrap.move()
gco.unwrap2.setFreeFormMode on
)


if selection.count>0 do
	(
geom=(for i in selection where superclassof i==GeometryClass collect i)
clearselection()
select geom

	gco_fn()
	if classof gco!=Unwrap_UVW
	then
			if ( (getfaceselection selection[1].mesh).numberset==0 and subobjectlevel==4 or subobjectlevel==5)
			then (subobjectlevel=0; modPanel.addModToSelection (Unwrap_UVW ()) ui:on; gco_fn(); FN_Unwrap_Editor(); subobjectlevel=1)
			else
			(geomSet=For obj in selection where superclassof obj == GeometryClass collect obj
			clearSelection(); select geomSet; modPanel.addModToSelection (Unwrap_UVW ()) ui:on
			gco_fn() -- update gco for Unwrap modifier
			FN_Unwrap_Editor()
			subobjectlevel=1)
	else (FN_Unwrap_Editor(); subobjectlevel=1)
	)
)