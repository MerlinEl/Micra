struct da (n,t,u,o)
setAppData $ -1000250 (#(da 1 2 "dfd" [4,4,2])as string) 
getAppData $ -1000250

setAppData $ 51  (#(da 8 82 "dfd" [48,84,28])as string) 
getAppData $ 51


<Interface>simpleFaceManager.addChannel <object>object type:<enum> id:<DWORD array> name:<string> 	 

object Validated by Validator function 	 
type enums: {#integer | #index | #float | #boolean | #point2 | #point3} 	 
type default value:	 #integer 	 
id default value: #() 	 
id Validated by Validator function 	 
name default value: undefined



FOR EXAMPLE 
obj = Plane length:60.0 width:60.0 widthsegs: 1 lengthsegs: 2
convertto obj Editable_Poly
idA = genClassID returnValue:true
channelA = simpleFaceManager.AddChannel obj type: #integer id:idA
channelA.name = "The Integer Channel"
channelA.SetValues #(5,2)
idB = genClassID returnValue:true
channelB = simpleFaceManager.AddChannel obj type: #float id:idB
channelB.name = "The Float Channel"
channelB.SetValues #(3.1459,7.236)



--continuing from the previous example on this page:
theInt = simpleFaceManager.getChannel obj idA

--continuing from the previous example on this page:
SimpleFaceManager.getChannels obj
--> #(<MixinInterface:simpleFaceChannel>, <MixinInterface:simpleFaceChannel>)

--continuing from the previous example on this page:
theInt = simpleFaceManager.getChannel obj idA
--> <MixinInterface:simpleFaceChannel>
theInt.name
--> "The Integer Channel"
theInt.type
--> #integer
theInt.numfaces
--> 2




fn applyObjectData node default:1 arr:#() = if isvalidnode node do
 (
 str = "attributes objectData 
 (
 parameters params rollout:params
 (
 index type:#integer ui:list default:%
 )
 rollout params \"Parameters\"
 (
 dropdownlist list \"The List:\" items:%
 )
 )
"

 ss = stringstream ""
 format str default (with printallelements on arr as string) to:ss
 objectData = execute (ss as string)
 free ss

 custAttributes.add node objectData baseobject:on
 )

 delete objects
 b = box name:"the_holder"
 applyObjectData b default:2 arr:#("One", "Two", "Three", "Four")
 select b
 max modify mode
 
 --
 b.
 
 
 
 
 the_weaponData = attributes weaponData
(
	parameters main rollout:params
	(
	hitPoints type: #float default:10
	cost type: #float  default:100
	sound type: #string
	)
	rollout params "Weapon Parameters"
	(
	)
)

custAttributes.add $ the_weaponData