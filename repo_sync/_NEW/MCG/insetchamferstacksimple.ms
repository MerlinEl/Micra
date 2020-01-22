plugin modifier InsetChamferStack
name:"InsetChamferStack"
classID:#(0x5abf6053, 0x1234b6e7)
extends:Smooth
replaceUI:false
(
	on attachedToNode obj do
	(
		delegate.autoSmooth = true
		delegate.preventIndirect = true
		replaceInstances this delegate

		local weldModifier = Vertex_Weld threshold:(units.decodeValue "0.1mm")
		local chamferModifier = Chamfer segments:2 tension:0.5 smoothingOption:2
		local insetModifier = ::InsetBySmoothingGroup inset_amount:chamferModifier.amount
		local emptyModifier = ::EmptyModifier name:"InsetChamfer"
		local attribs = attributes attribs attribID:#(0x13e03b5c, 0x59021f14)
		(
			parameters main rollout:params
			(
				inset type:#float ui:spnInset
				chamfer type:#float ui:spnChamfer
				segments type:#float ui:spnSegments
			)
			
			rollout params "Parameters"
			(
				spinner spnInset "Inset: " type:#float range:[1e-9, 1e9, 1]
				spinner spnChamfer "Chamfer: " type:#float range:[1e-9, 1e9, 1]
				spinner spnSegments "Segments: " type:#integer range:[1, 100, 2]
			)
		)

		modPanel.addModToSelection insetModifier
		modPanel.addModToSelection weldModifier
		modPanel.addModToSelection chamferModifier
		modPanel.addModToSelection emptyModifier

		custAttributes.add emptyModifier attribs
		insetModifier.inset.controller = Bezier_float()
		chamferModifier.amount.controller = Bezier_float()
		chamferModifier.segments.controller = Linear_float()
		emptyModifier.attribs.inset.controller = insetModifier.inset.controller
		emptyModifier.attribs.chamfer.controller = chamferModifier.amount.controller
		emptyModifier.attribs.segments.controller = chamferModifier.segments.controller
	)
)