macroScript monsterScaleUVsByNumber
	category:"monsterBlues"
	toolTip:"UV: Scale UVs By Number"
	buttonText:"Scale UVs"
(
	rollout rolloutScaleUVByNumber "Scale UVs"
	(
		spinner spnPercent "Percent: " range:[-999,999,100]
		radioButtons rdoAxis " " labels:#("XY","X","Y") default:1 offset:[0,-16]
		button btnScale "Scale"
		
		on btnScale pressed do
		(
			if classof (modPanel.getCurrentObject()) == Unwrap_UVW do
			(
				try
				(
					undo "Scale UVWs" on
					(
						selection[1].unwrap_uvw.unwrap2.ScaleSelectedCenter (spnPercent.value/100.0) (rdoAxis.state-1)
					)
				)
				catch
				(
					messageBox "An unwrap modifier must be the active selection." title:"Didn't Work"
				)
			)
		)
	)

	createDialog rolloutScaleUVByNumber
)