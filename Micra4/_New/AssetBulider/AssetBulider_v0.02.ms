rollout mcAssetGeneratorDialog "Asset Builder:" width:664 height:416
(
	local scotch_root_path	= "D:\\!2k_games\scotch_dev\\"
	local temp_edt_path		= "models\\city\\lost_heaven\\districts\lh_08_oakwood\\"
	local temp_res_path		= "graphics\city\\lost_heaven\districts\\lh_08_oakwood\\static_objects\\"
	local temp_asset_name	= "lh_08_family_house_a_v1"
	GroupBox 'grp1' "3DsMax:" pos:[4,104] width:656 height:72 align:#left
	label 'lbl1' "Create Material:" pos:[12,126] width:84 height:16 align:#left
	label 'lbl2' "Create Material:" pos:[12,314] width:84 height:16 align:#left
	checkbox 'chk_create_fussion_mat' "" pos:[100,316] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl3' "Create PSD:" pos:[12,206] width:84 height:16 align:#left
	checkbox 'chk_create_psd' "" pos:[101,204] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl4' "width:" pos:[128,206] width:36 height:16 align:#left
	spinner 'spn_psd_h' "" pos:[287,206] width:72 height:16 range:[0,10000,2048] align:#left
	label 'lbl5' "height:" pos:[246,206] width:36 height:16 align:#left
	spinner 'spn_psd_w' "" pos:[169,204] width:72 height:16 range:[0,10000,1024] align:#left
	label 'lbl6' "Edit Path         :  D:\\!2k_games\scotch_dev\\edit\\" pos:[12,48] width:262 height:16 align:#left
	label 'lbl73' "Resource Path:  D:\\!2k_games\scotch_dev\\resources\\" pos:[12,68] width:262 height:16 align:#left
	edittext 'edt_edt_path' "" pos:[275,48] width:353 height:16 align:#left
	edittext 'edt_res_path' "" pos:[275,68] width:353 height:16 align:#left
	label 'lbl7' "Create Node:" pos:[12,150] width:84 height:16 align:#left
	button 'btn_browse_export_path' "..." pos:[632,48] width:20 height:16 align:#left
	GroupBox 'grp2' "Photoshop:" pos:[4,184] width:656 height:100 align:#left
	checkbox 'chk_export_psd_diffuse' "" pos:[100,252] width:23 height:20 checked:true align:#left
	label 'lbl10' "Export Diffuse:" pos:[12,254] width:84 height:16 align:#left
	checkbox 'chk_generate_psd_layers' "" pos:[100,228] width:23 height:20 checked:true align:#left
	label 'lbl11' "Generate Layers:" pos:[12,230] width:84 height:16 align:#left
	GroupBox 'grp3' "Fussion:" pos:[4,292] width:656 height:76 align:#left
	label 'lbl12' "Assign Diffuse:" pos:[12,338] width:84 height:16 align:#left
	checkbox 'chk7' "" pos:[100,340] width:23 height:20 enabled:true checked:true align:#left
	button 'btn2' "GENERATE ASSET" pos:[4,372] width:656 height:40 align:#left
	GroupBox 'grp19' "Global:" pos:[4,4] width:656 height:88 align:#left
	button 'btn13' "..." pos:[632,68] width:20 height:16 align:#left
	label 'lbl74' "Asset Name:" pos:[12,26] width:84 height:16 align:#left
	edittext 'edt_asset_name' "" pos:[96,24] width:548 height:16 align:#left
	checkbox 'chk48' "" pos:[100,124] width:23 height:20 enabled:true checked:true align:#left
	checkbox 'chk49' "" pos:[100,148] width:23 height:20 enabled:true checked:true align:#left
	on mcAssetGeneratorDialog open do 
	(
		edt_asset_name.text		= temp_asset_name
		edt_edt_path.text		= temp_edt_path
		edt_res_path.text		= temp_res_path
		-- btn_browse_export_path
	)
)
createDialog mcAssetGeneratorDialog