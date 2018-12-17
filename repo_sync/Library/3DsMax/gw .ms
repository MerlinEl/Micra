if selection.count !=0 do gw.hMarker ( gw.hTransPoint $.pos) #circle color:green -- project green circle to object pos
if selection.count !=0 do gw.hMarker ( gw.hTransPoint [$.pos.x,$.pos.y,0] ) #circle color:green -- 3d object pos projected on grid



gw.getTextExtent "Materials"