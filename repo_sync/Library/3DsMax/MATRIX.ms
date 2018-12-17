--MATRIX

myTransform = $.transform
myTransform.row4 = [10.0,0.0,0.0] 
$.transform = myTransform
myTransform.translation 


addmodifier $ (xform())
(xform()).gizmo.transform=$.transform
(xform()).gizmo.rotation = (quat 0 0 0 1)