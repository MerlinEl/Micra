---------------
---------------
--	         --
--	Cleaner  --
--	         --
---------------
---------------

		/*
		local mcDialogs = getIniSetting mcTempProfileIni "Properties_2"
		local mcDialogsNet = getIniSetting mcTempProfileIni "Properties_1"
		for d in mcDialogs do
		(
			local dia = execute d
			if dia != undefined and dia.isDisplayed do destroyDialog dia
		) 
		for d in mcDialogsNet do
		(
			local dia = execute d
			if dia != undefined and dia.HasChildren do dia.Close()
		)

		*/

-->Close All Dialogs
try ( mc_Dialog_A.close() ) catch()
try ( mc_Dialog_B.close() ) catch()
try ( mc_Dialog_C.close() ) catch()
try ( mc_Dialog_D.close() ) catch()
try ( mc_Dialog_E.close() ) catch()
try ( mc_Dialog_F.close() ) catch()
try ( mc_Dialog_G.close() ) catch()
try ( mc_Dialog_H.close() ) catch()
try ( mc_Dialog_I.close() ) catch()
try ( mc_Dialog_J.close() ) catch()

mc_Dialog_A = undefined
mc_Dialog_B = undefined
mc_Dialog_C = undefined
mc_Dialog_D = undefined
mc_Dialog_E = undefined
mc_Dialog_F = undefined
mc_Dialog_G = undefined
mc_Dialog_H = undefined
mc_Dialog_I = undefined
mc_Dialog_J = undefined

-->Unload Calbacks
if mcPolyCount != undefined do unregisterRedrawViewsCallback mcPolyCount.Count
mcPolyCount = undefined			
unregisterRedrawViewsCallback mcCall.fileName_in_screen 
unregisterRedrawViewsCallback mcAction.triangle_counter
callbacks.removeScripts id:#mcGeneralCall

-->Unload Variables
mc_Dialog_DragSource = undefined
mc_Dialog_DropTarget = undefined

gc()
completeredraw()
print "Unloader.ms is Done!"
