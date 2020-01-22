plugin modifier InsetChamferStack
name:"InsetChamferStack"
classID:#(0x5abf6053, 0x1234b6e7)
extends:Smooth
replaceUI:false
(
	local cloned = false
	local counter = 0
	local smoothModifier
	local weldModifier
	local chamferModifier
	local insetModifier
	local emptyModifier
	local insetChamferParams
	
	on create do
	(
		this.name = "Smooth"
		delegate.autoSmooth = true
		delegate.preventIndirect = true
		replaceInstances this delegate

		smoothModifier = delegate
		weldModifier = Vertex_Weld threshold:(units.decodeValue "0.1mm")
		chamferModifier = Chamfer segments:2 tension:0.5 smoothingOption:2
		insetModifier = ::InsetBySmoothingGroup inset:(1.1 * chamferModifier.amount)
		emptyModifier = ::EmptyModifier name:"InsetChamfer"
		insetChamferParams = attributes insetChamferParams attribID:#(0x13e03b5c, 0x59021f14)
		(
			parameters main rollout:params
			(
				inset type:#worldUnits ui:spnInset
				chamfer type:#worldUnits ui:spnChamfer
				segments type:#integer ui:spnSegments
				smooth type:#boolean ui:chxSmooth default:true
				smoothAngle type:#angle ui:spnSmoothAngle
				smoothMod type:#maxObject invisibleInTV:true 
				threshold type:#worldUnits ui:spnThresh

				on smooth set state do if isKindOf smoothMod RefTargContainer do (smoothMod.getItem 1).enabled = state
			)

			rollout params "Parameters"
			(
				group "Basic"
				(
					spinner spnInset "Inset: " type:#worldUnits range:[1e-9, 1e9, 1]
					spinner spnChamfer "Chamfer: " type:#worldUnits range:[1e-9, 1e9, 1]
					spinner spnSegments "Segments: " type:#integer range:[1, 100, 2]
				)
				group "Tweaks"
				(
					spinner spnThresh "Weld Thresh.: " type:#worldUnits fieldWidth:65 range:[1e-9, 1e9, 1e-3]
					checkBox chxSmooth "Smooth" across:2
					spinner spnSmoothAngle type:#float fieldWidth:65 range:[0, 360, 30] enabled:smooth
				)

				on params open do if isKindOf smoothMod RefTargContainer do chxSmooth.state = (smoothMod.getItem 1).enabled
				on chxSmooth changed state do spnSmoothAngle.enabled = state
			)
		)
	)

	on attachedToNode obj do if not cloned and (counter += 1) == selection.count do
	(
		modPanel.addModToSelection insetModifier
		modPanel.addModToSelection weldModifier
		modPanel.addModToSelection chamferModifier
		modPanel.addModToSelection emptyModifier

		custAttributes.add emptyModifier insetChamferParams
		emptyModifier.insetChamferParams.smoothMod = RefTargContainer()
		emptyModifier.insetChamferParams.smoothMod.appendItem this

		smoothModifier.threshold.controller = Bezier_float()
		weldModifier.threshold.controller = Bezier_float()
		insetModifier.inset.controller = Bezier_float()
		chamferModifier.amount.controller = Bezier_float()
		chamferModifier.segments.controller = Linear_float()

		emptyModifier.insetChamferParams.smoothAngle.controller = smoothModifier.threshold.controller
		emptyModifier.insetChamferParams.threshold.controller = weldModifier.threshold.controller
		emptyModifier.insetChamferParams.inset.controller = insetModifier.inset.controller
		emptyModifier.insetChamferParams.chamfer.controller = chamferModifier.amount.controller
		emptyModifier.insetChamferParams.segments.controller = chamferModifier.segments.controller
	)

	on clone original do cloned = true
)