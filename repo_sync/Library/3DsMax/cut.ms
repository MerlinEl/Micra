startCut = polyop.getvert $ 4
endCut = polyop.getvert $ 11

subobjectLevel = 1
$.cutStartLevel = 2
$.cutStartIndex = 10
$.cutStartCoords = startCut
$.cutEndCoords = endCut
$.cutNormal = [-0.628525,-0.506355,0.59039]



obj = $selection[1]
statrVert = 4
endPos = [10,20,0]
viewDirection = [1,0,0]
obj.cutVertices statrVert endPos viewDirection




--cur from viewport rotation
polyop.setsliceplane $ (ray $.pos (inverse (viewport.getTM()))[3]) 10