progbar.value = 100.*i/selected_items.count 


if  PolyCollapseToOriginDialog != undefined destroyDialog PolyCollapseToOriginDialog
rollout PolyCollapseToOriginDialog "Progress Bar" width:525 height:40
(
	label lbl4 "Progress" pos:[4,4] width:505 height:20
	progressBar pb3 "" pos:[4,24] width:505 height:8 color:(color 30 10 190)
)
createdialog PolyCollapseToOriginDialog

ObjStep = 0
ProgressSteps = 100 / CurrentselectionArray.count


for SourceObj in CurrentselectionArray where (superclassof SourceObj == GeometryClass) do
					(
					with redraw off
						(
							SourceObjBoxmode = SourceObj.Boxmode
							SourceObjShowFrozenInGray = SourceObj.ShowFrozenInGray
							SourceObjBackfacecull = SourceObj.Backfacecull
							SourceObjAlledges = SourceObj.Alledges
							SourceObjXray = SourceObj.Xray
							SourceObjIgnoreExtents = SourceObj.IgnoreExtents
							SourceObjVertexTicks = SourceObj.VertexTicks
							SourceObjShowTrajectory = SourceObj.ShowTrajectory
							SourceObjRenderable = SourceObj.Renderable
							SourceObjCastShadows = SourceObj.CastShadows
							SourceObjReceiveshadows = SourceObj.Receiveshadows
							SourceObjApplyAtmospherics = SourceObj.ApplyAtmospherics
							SourceObjMotionblur = SourceObj.Motionblur
							SourceObjInheritVisibility = SourceObj.InheritVisibility
							SourceObjRenderOccluded = SourceObj.RenderOccluded
							SourceObjPrimaryVisibility = SourceObj.PrimaryVisibility
							SourceObjSecondaryVisibility = SourceObj.SecondaryVisibility
							SourceObjMotionBlurOn = SourceObj.MotionBlurOn
							SourceObjTransformLocks = getTransformLockFlags SourceObj
							SourceObjgBufferChannel = SourceObj.gBufferChannel
							SourceObjMotionBlurType = SourceObj.motionBlur
							SourceObjMBMultiplier = SourceObj.imageMotionBlurMultiplier

PolyCollapseToOriginDialog.ProgressInfo.caption = ("Object: " + SourceObjName as string)
PolyCollapseToOriginDialog.PolyCollapseToOrigin.value = ProgressSteps * ObjStep

						)
					)