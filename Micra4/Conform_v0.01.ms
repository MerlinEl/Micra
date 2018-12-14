/*
[DESCRIPTION]
This script will conform one mesh to the surface of another mesh or meshes. 
What the script does is shoot a ray from each verts positive and negative directions. 
It will do this with the taget mesh once then again with its' normals flipped. 
It will find which ray is the shortest then move that vert to that location.

Once the mesh is conformed a morph modifier is added to the original mesh and 
the new conformed mesh is added as a target and the mesh is deleted. You can then 
collapse the mesh or delet the modifier then rerun the script.  If the morph modifier 
already exists then a new target will be added to the existing morph modifier.

[USAGE]
Select the object you wish to conform.
Run this script
Then pick the object(s) you want to conform to.

[CREATION INFO]
Author:Paul Hormis
Last Updated: January 23, 2005

[VERSION HISTORY]
v1.00	Created
v2.00	Initial Public Posting

Copyright (C) 2004, 2005  Paul Hormis

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

paul@time-in-motion.com
*/


Global ConformMesh

Struct ConformMeshStruct
	(
		fn FindMeshIntNegative DobjPos DobjDir DSurf =
			(
				Dray = ray DobjPos -DobjDir
				DIntersect = intersectRayex DSurf Dray
				TestDist = distance DobjPos DIntersect[1].pos
				return #(TestDist, DIntersect)
			),

		fn FindMeshIntPositive DobjPos DobjDir DSurf =
			(
				Dray = ray DobjPos DobjDir
				DIntersect = intersectRayex DSurf Dray
				TestDist = distance DobjPos DIntersect[1].pos
				return #(TestDist, DIntersect)
			),			
			
		fn ShrinkAlreadySelected FilterObj =
			(
				if (FilterObj == $) then
					(return false)
					else
					(return true)
			),
		
		fn DoConformMesh =
			(
				CurrentSelectedMesh = $
				ConformMorphTarget = undefined
				if CurrentSelectedMesh != undefined do
					(
						TargetObjects = selectByName title:"Select Target objects" buttontext:"Conform" filter:ShrinkAlreadySelected

						if TargetObjects != undefined do
							undo "Conform" on
							(
								TargetObjectSnaps = #()
								SelectedVertsArray = #()
								ShrinkSelectedVerts = undefined
								ShrinkWrapMesh = undefined
								
								if subobjectlevel == 1 do
									(
										case (classof CurrentSelectedMesh) of
											(
												Editable_Poly:	(;SelectedVertsArray = (polyOp.GetVertSelection CurrentSelectedMesh) as array;ShrinkSelectedVerts = true;)
												Editable_Mesh:	(;SelectedVertsArray = (GetVertSelection CurrentSelectedMesh) as array;ShrinkSelectedVerts = true;)
											)
									)

								if ShrinkSelectedVerts == true then
									(;ShrinkWrapMesh = SnapShot CurrentSelectedMesh;ShrinkWrapMesh.name = (CurrentSelectedMesh.name + "_ConformMesh");)
									else
									(;ShrinkWrapMesh = SnapShot CurrentSelectedMesh;ShrinkWrapMesh.name = (CurrentSelectedMesh.name + "_ConformMesh");)
								
								for x in TargetObjects do (append TargetObjectSnaps (snapshot x))
								for x = 1 to TargetObjectSnaps.count do (TargetObjectSnaps[x].name = (TargetObjectSnaps[x].name + "_TargetObjTemp" + "_" + x as string))

								select TargetObjectSnaps[1]
								for x = 2 to TargetObjectSnaps.count do (attach TargetObjectSnaps[1] TargetObjectSnaps[x])
								TargetSurf = TargetObjectSnaps[1]

								if (classof TargetSurf) != Editable_mesh do (;addmodifier TargetSurf (Mesh_Select());TargetSurf.modifiers[1].name = "Conform MeshSelect";)

								progressSteps = undefined

								if ShrinkSelectedVerts == true then (progressSteps = 100.0 / SelectedVertsArray.count) else (progressSteps = 100.0 / (GetNumVerts ShrinkWrapMesh))

								rollout ConformProgressDialog "ShrinkWrap Progress" width:525 height:32
									(
										label ShrinkWrapProgressInfo "Test" pos:[10,2] width:300 height:15
										label CurrentVertLabel "Vertex:" pos:[400,2] width:35 height:15
										label CurrentVert "" pos:[440,2] width:80 height:15
										progressBar ShrinkWrapSubProgress "" pos:[10,17] width:505 height:7 color:blue
										progressBar ShrinkWrapProgress "" pos:[10,23] width:505 height:7 color:green
									)
								createdialog ConformProgressDialog
								
								----Progress Update----
								ConformProgressDialog.ShrinkWrapSubProgress.value = 10
								----Progress Update----
								
								with redraw off
								(
									CurrentCommandMode = getCommandPanelTaskMode()
									
									LocationArray = #()
									SkippedVertArray = #{}
								
									max create mode
									
									----Progress Update----
									ConformProgressDialog.ShrinkWrapSubProgress.value = 25
									----Progress Update----
									
									if ShrinkSelectedVerts == true then
										(
											for x in SelectedVertsArray do 
												(
													dpos = (GetVert ShrinkWrapMesh x)
													ddir = (getNormal ShrinkWrapMesh x)
											
													TestZPos = (try (FindMeshIntPositive dpos ddir TargetSurf) catch ())
													TestZNeg = (try (FindMeshIntNegative dpos ddir TargetSurf) catch ())
													
													addmodifier TargetSurf (NormalModifier())
													TargetSurf.modifiers[1].name = "ConformMeshNormalMod"
													TargetSurf.modifiers[#ConformMeshNormalMod].flip = on
													
													TestZPosFlip = (try (FindMeshIntPositive dpos ddir TargetSurf) catch ())
													TestZNegFlip = (try (FindMeshIntNegative dpos ddir TargetSurf) catch ())
													
													deleteModifier TargetSurf TargetSurf.modifiers[#ConformMeshNormalMod]
													
													DistanceArray = #()
													ShortestDistance = #()
													NewPos = undefined

													if TestZPos != undefined do (append DistanceArray TestZPos[1])
													if TestZNeg != undefined do (append DistanceArray TestZNeg[1])
													if TestZPosFlip != undefined do (append DistanceArray TestZPosFlip[1])
													if TestZNegFlip != undefined do (append DistanceArray TestZNegFlip[1])
													
													if (TestZPos == undefined) and (TestZNeg == undefined) and (TestZPosFlip == undefined) and (TestZNegFlip == undefined) then
														(
															NewPos = "Skip"
														)
														else
														(
															sort DistanceArray
															ShortestDistance = DistanceArray[1]
															
															if ((try (finditem TestZPos ShortestDistance) catch()) != undefined) and ((try (finditem TestZPos ShortestDistance) catch()) != 0) do (newPos = (TestZPos[2])[1].pos)
															if ((try (finditem TestZNeg ShortestDistance) catch()) != undefined) and ((try (finditem TestZNeg ShortestDistance) catch()) != 0) do (newPos = (TestZNeg[2])[1].pos)
															if ((try (finditem TestZPosFlip ShortestDistance) catch()) != undefined) and ((try (finditem TestZPosFlip ShortestDistance) catch()) != 0) do (newPos = (TestZPosFlip[2])[1].pos)
															if ((try (finditem TestZNegFlip ShortestDistance) catch()) != undefined) and ((try (finditem TestZNegFlip ShortestDistance) catch()) != 0) do (newPos = (TestZNegFlip[2])[1].pos)
														)
													append LocationArray newPos
													gc()
													----Progress Update----
													ConformProgressDialog.ShrinkWrapProgressInfo.caption = ("Finding New Vertex Positions")
													ConformProgressDialog.ShrinkWrapProgress.value = progressSteps * x
													ConformProgressDialog.CurrentVert .caption= (x as string + "/" + SelectedVertsArray.count as string)
													----Progress Update----
												)
										)
										else
										(
											for i = 1 to (GetNumVerts ShrinkWrapMesh) do 
												(
													dpos = (GetVert ShrinkWrapMesh i)
													ddir = (getNormal ShrinkWrapMesh i)
											
													TestZPos = (try (FindMeshIntPositive dpos ddir TargetSurf) catch ())
													TestZNeg = (try (FindMeshIntNegative dpos ddir TargetSurf) catch ())
													
													addmodifier TargetSurf (NormalModifier())
													TargetSurf.modifiers[1].name = "ConformMeshNormalMod"
													TargetSurf.modifiers[#ConformMeshNormalMod].flip = on
													
													TestZPosFlip = (try (FindMeshIntPositive dpos ddir TargetSurf) catch ())
													TestZNegFlip = (try (FindMeshIntNegative dpos ddir TargetSurf) catch ())
													
													deleteModifier TargetSurf TargetSurf.modifiers[#ConformMeshNormalMod]
													
													DistanceArray = #()
													ShortestDistance = #()
													NewPos = undefined

													if TestZPos != undefined do (append DistanceArray TestZPos[1])
													if TestZNeg != undefined do (append DistanceArray TestZNeg[1])
													if TestZPosFlip != undefined do (append DistanceArray TestZPosFlip[1])
													if TestZNegFlip != undefined do (append DistanceArray TestZNegFlip[1])
													
													if (TestZPos == undefined) and (TestZNeg == undefined) and (TestZPosFlip == undefined) and (TestZNegFlip == undefined) then
														(
															NewPos = "Skip"
														)
														else
														(
															sort DistanceArray
															ShortestDistance = DistanceArray[1]
															
															if ((try (finditem TestZPos ShortestDistance) catch()) != undefined) and ((try (finditem TestZPos ShortestDistance) catch()) != 0) do (newPos = (TestZPos[2])[1].pos)
															if ((try (finditem TestZNeg ShortestDistance) catch()) != undefined) and ((try (finditem TestZNeg ShortestDistance) catch()) != 0) do (newPos = (TestZNeg[2])[1].pos)
															if ((try (finditem TestZPosFlip ShortestDistance) catch()) != undefined) and ((try (finditem TestZPosFlip ShortestDistance) catch()) != 0) do (newPos = (TestZPosFlip[2])[1].pos)
															if ((try (finditem TestZNegFlip ShortestDistance) catch()) != undefined) and ((try (finditem TestZNegFlip ShortestDistance) catch()) != 0) do (newPos = (TestZNegFlip[2])[1].pos)
														)
													append LocationArray newPos
													gc()
													----Progress Update----
													ConformProgressDialog.ShrinkWrapProgressInfo.caption = ("Finding New Vertex Positions")
													ConformProgressDialog.ShrinkWrapProgress.value = progressSteps * i
													ConformProgressDialog.CurrentVert .caption= (i as string + "/" + (GetNumVerts ShrinkWrapMesh) as string)
													----Progress Update----
												)
										)

									----Progress Update----
									ConformProgressDialog.ShrinkWrapProgress.value = 0;ConformProgressDialog.ShrinkWrapSubProgress.value = 50
									----Progress Update----

									if ShrinkSelectedVerts == true then
										(
											CurrentVertInArray = 1
											for x in SelectedVertsArray do
												(
													if LocationArray[CurrentVertInArray] != "Skip" then
														(
														setVert ShrinkWrapMesh x LocationArray[CurrentVertInArray]
														)
														else
														(append SkippedVertArray x)
														CurrentVertInArray += 1
													----Progress Update----
													ConformProgressDialog.ShrinkWrapProgressInfo.caption = ("Moving Verts")
													ConformProgressDialog.ShrinkWrapProgress.value = progressSteps * CurrentVertInArray
													ConformProgressDialog.CurrentVert .caption = (CurrentVertInArray as string + "/" + SelectedVertsArray.count as string)
													----Progress Update----
												)
										)
										else
										(
											for i = 1 to (GetNumVerts ShrinkWrapMesh) do
												(
													if LocationArray[i] != "Skip" then
														(setVert ShrinkWrapMesh i LocationArray[i])
														else
														(append SkippedVertArray i)
													----Progress Update----
													ConformProgressDialog.ShrinkWrapProgressInfo.caption = ("Moving Verts")
													ConformProgressDialog.ShrinkWrapProgress.value = progressSteps * i
													ConformProgressDialog.CurrentVert .caption = (i as string + "/" + (GetNumVerts ShrinkWrapMesh) as string)
													----Progress Update----
												)
										)
									
									update ShrinkWrapMesh
									
									----Progress Update----
									ConformProgressDialog.ShrinkWrapProgress.value = 0
									----Progress Update----
									
									subobjectlevel = 1
									setVertSelection shrinkWrapMesh SkippedVertArray
									setCommandPanelTaskMode mode:#modify
								
									----Progress Update----
									ConformProgressDialog.ShrinkWrapProgressInfo.caption = ("Relaxing Skipped Verts");ConformProgressDialog.ShrinkWrapSubProgress.value = 70
									----Progress Update----
									
									addmodifier ShrinkWrapMesh (Relax ())
									ShrinkWrapMesh.modifiers[#Relax].Keep_Boundary_Pts_Fixed = 0
									ShrinkWrapMesh.modifiers[#Relax].Relax_Value = 0.5
									ShrinkWrapMesh.modifiers[#Relax].iterations = 10
									modPanel.setCurrentObject ShrinkWrapMesh.baseObject
									subobjectLevel = 1
								
									----Progress Update----
									ConformProgressDialog.ShrinkWrapSubProgress.value = 95
									----Progress Update----
								
									modPanel.setCurrentObject ShrinkWrapMesh.modifiers[#Relax]
									addmodifier ShrinkWrapMesh (Mesh_Select())
									ConformProgressDialog.ShrinkWrapProgressInfo.caption = ("Finalizing")
									
									--clearSelection()
									
									delete TargetSurf
								
									----Progress Update----
									ConformProgressDialog.ShrinkWrapSubProgress.value = 100
									----Progress Update----
								
									ConformMorphTarget = snapshot ShrinkWrapMesh
									if CurrentSelectedMesh.modifiers[#ConformMorph] == undefined then
										(
											select CurrentSelectedMesh
											modPanel.addModToSelection (morpher ())
											CurrentSelectedMesh.modifiers[1].name = "ConformMorph"
											ConformMorphTarget.name = "ConformMorph"
											WM3_MC_BuildFromNode CurrentSelectedMesh.modifiers[1] 1 ConformMorphTarget
											modPanel.setCurrentObject CurrentSelectedMesh.modifiers[1]
											WM3_MC_SetValue $.modifiers[1] 1 100.0
										)
										else
										(
											select CurrentSelectedMesh
											modPanel.addModToSelection (morpher ())
											CurrentSelectedMesh.modifiers[1].name = "ConformMorph"
											ConformMorphTarget.name = "ConformMorph"
											WM3_MC_BuildFromNode CurrentSelectedMesh.modifiers[1] 1 ConformMorphTarget
											modPanel.setCurrentObject CurrentSelectedMesh.modifiers[1]
											WM3_MC_SetValue $.modifiers[1] 1 100.0
										)

									setCommandPanelTaskMode mode:CurrentCommandMode

									delete ShrinkWrapMesh
									delete ConformMorphTarget									
									destroyDialog ConformProgressDialog
									forceCompleteRedraw()
							)
					)
				)
			)
	)
ConformMesh = ConformMeshStruct()
ConformMesh.DoConformMesh()
