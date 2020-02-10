--------------------------------------------------------------------------------
/* mcSecurity by Orien 2020 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
	mcDotnet
	mcFile
*
*@Used Objects

*
*@Example
	mcSecurity.progeressbar a.ProgressPercentage msg:"Downoading Update:"
	if a.ProgressPercentage >= 100 do mcSecurity.progeressbar 100 msg:"Downoad Finished:" close:true 
*/
Struct MICRA_SECURITY_POPUP (

	fn getSource = getSourceFileName(), --get path of this script
	fn progeressBar val color:(color 255 200 18) msg:"Progress..." image:"default" close:false = (
	
		if mcProgressBarDialog == undefined do
		(
			rollout mcProgressBarDialog " Inicialize Gallery3D Database:" width:332 height:132
			(
				GroupBox grp_info "Progress...0%" pos:[8,4] width:316 height:120
				bitmap bmpPop1 "Bitmap" pos:[16,20] width:300 height:80 fileName:(Micra.RootDir+"Img\\3DGall_Loader_01.bmp")
				progressBar pBar "ProgressBar" pos:[16,104] width:300 height:13
				button btn_close "*" pos:[312,4] width:12 height:12
				on btn_close pressed do destroyDialog mcProgressBarDialog
			)
			createDialog mcProgressBarDialog style:#(#style_border) --modal:true
			mcProgressBarDialog.pBar.color = color
		)
		if not mcProgressBarDialog.isDisplayed then
		(
			createDialog mcProgressBarDialog style:#(#style_border) --modal:true
			mcProgressBarDialog.pBar.color = color
		)
		mcProgressBarDialog.pBar.value    = val
		mcProgressBarDialog.grp_info.text = msg +"( "+ ((val as integer) as string) + " )%"
		if close do (sleep 0.3; destroyDialog mcProgressBarDialog)
	)
	/*<end>*/
)
 --create instance
Global mcSecurity = mcStructMan.instanceStructure MICRA_SECURITY_POPUP "mcSecurity"