
gco = modPanel.getCurrentObject()
mcsystem.show gco
gco.setMapChannel 1
gco.getMapChannel()


fn clearChannels cmin cmax =
(
	local obj = selection[1]
	if obj == undefined do return false
	for i=cmax to cmin by -1 do with redraw Off (channelInfo.ClearChannel obj i)
	convertToPoly obj
)
clearChannels 2 99	
	
	
	
	mcsystem.show channelInfo
	
 Properties:
    .subComp : boolean : Read|Write
    .lock : boolean : Read|Write
   Methods:
    <void>dialog()
    <void>closeDialog()
    <boolean>isChecked()
    <void>CopyChannel <node>node <integer>channelType <integer>channel
    <void>CopySubChannel <node>node <integer>channelType <integer>channel <integer>subchannel
    <void>PasteChannel <node>node <integer>channelType <integer>channel
    <void>PasteSubChannel <node>node <integer>channelType <integer>channel <integer>subchannel
    <void>AddChannel <node>node
    <void>ClearChannel <node>node <integer>channel
    <void>NameChannel <node>node <integer>channelType <integer>channel <string>name
    <void>NameSubChannel <node>node <integer>channelType <integer>channel <integer>subchannel <string>name
    <void>update()



ChannelInfo.PasteSubChannel $ 2 25 1
ChannelInfo.NameSubChannel $ 2 25 1 "sel test1"

channelInfo.ClearChannel $ 2	
		
		
		--swap UV faces
		channelInfo.CopyChannel theNewMesh 1 0;--copy Geometry to #0
		channelInfo.PasteChannel theNewMesh 3 2;--paste UVmap to #2;
		channelInfo.CopyChannel theNewMesh 3 1;--copy UVmap to #1
		channelInfo.PasteChannel theNewMesh 3 3;--paste UVmap to #3;
		channelInfo.CopyChannel theNewMesh 3 2;--copy UVmap to #2
		channelInfo.PasteChannel theNewMesh 3 1;--paste UVmap to #1
		channelInfo.CopyChannel theNewMesh 3 3;--copy UVmap to #3
		channelInfo.PasteChannel theNewMesh 1 0;--paste Geometry to #0;
		channelInfo.ClearChannel theNewMesh 2;--clear channel 2
		channelInfo.ClearChannel theNewMesh 3;--clear channel 3
		
		
--FACES		
polyOp.getNumMaps $
polyOp.setNumMaps $ 100 keep:true -- true keeps old mapping
polyOp.setNumMapFaces $ 25 $.faces.count keep:true
polyOp.getNumMapFaces $ 1
polyOp.setMapFace $ 25 <int map face index> <map vertex array>
polyOp.getMapFace $ <int mapChannel> <int index>


--VERTICES
polyOp.getNumVDataChannels $
polyOp.setNumVDataChannels $ 25
polyOp.getVDataChannelSupport $ 25

polyOp.setVDataChannelSupport $ 25 true
polyOp.setVDataValue $ 25 $.verts 1.0
polyOp.getVDataValue $ 25 1


--MODIFIER
Select_By_Channel

<Select_By_Channel>.selectionType Integer default: 0 -- integer; 
<Select_By_Channel>.mapID Integer default: 0 -- integer; Map_ID
<Select_By_Channel>.mapSubID Integer default: 0 -- integer; Map_Sub_ID




--VData
polyOp.setNumVDataChannels $ 6 keep:TRUE
polyOp.setVDataChannelSupport $ 6 TRUE
polyOp.setVDataValue $ 6 $.verts 1.1
polyOp.getVDataValue $ 6 1

polyOp.getNumVDataChannels $
polyOp.getVDataChannelSupport $ 25


--EData
polyOp.setNumEDataChannels $ 5 keep:TRUE
polyOp.setEDataChannelSupport $ 5 TRUE
polyOp.setEDataValue $ 5 #{1..10} 2.5
polyOp.getEDataValue $ 5 1

polyOp.getEDataChannelSupport $ 5
polyOp.getNumEDataChannels $