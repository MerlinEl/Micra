--A plugin that I wrote to “replace” the Point helpers in my scenes.
--Anubis
--Posted: 27 August 2010 08:48 AM

plugin simpleObject NullMesh name:"NullMesh" 
    classID:#(0x54d46cf3, 0x5ed54ad6) 
    category:"Scripted Primitives"
    invisible:true version:1
(
    on buildMesh do
    (
       setMesh mesh numverts:0 numfaces:0
    )
    on attachedToNode obj do
    (
       obj.renderable = off
       obj.wirecolor = black
    )
 )