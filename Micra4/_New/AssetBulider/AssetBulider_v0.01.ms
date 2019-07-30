rollout mcAssetGeneratorDialog "Asset Builder:" width:664 height:416
(
	GroupBox 'grp1' "3DsMax:" pos:[4,104] width:656 height:72 align:#left
	label 'lbl1' "Create Material:" pos:[12,126] width:84 height:16 align:#left
	label 'lbl2' "Create Material:" pos:[12,314] width:84 height:16 align:#left
	checkbox 'chk_create_fussion_mat' "" pos:[100,316] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl3' "Create PSD:" pos:[12,206] width:84 height:16 align:#left
	checkbox 'chk_create_psd' "" pos:[101,204] width:23 height:20 enabled:true checked:true align:#left
	label 'lbl4' "width:" pos:[129,222] width:36 height:16 align:#left
	spinner 'spn_psd_h' "" pos:[288,222] width:72 height:16 range:[0,10000,2048] align:#left
	label 'lbl5' "height:" pos:[247,222] width:36 height:16 align:#left
	spinner 'spn_psd_w' "" pos:[170,220] width:72 height:16 range:[0,10000,1024] align:#left
	label 'lbl6' "Export Path:" pos:[12,48] width:84 height:16 align:#left
	edittext 'edt_export_path' "" pos:[96,48] width:532 height:16 align:#left text:"D:\!2k_games\scotch_dev\edit\models\city\lost_heaven\districts\lh_08_oakwood"
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
	label 'lbl73' "Resource Path:" pos:[12,68] width:84 height:16 align:#left
	edittext 'edt19' "" pos:[96,68] width:532 height:16 align:#left text:"D:\\!2k_games\\scotch_dev\\resources\\graphics\city\\lost_heaven\districts\\lh_08_oakwood\\static_objects"
	button 'btn13' "..." pos:[632,68] width:20 height:16 align:#left
	label 'lbl74' "Building Name:" pos:[12,26] width:84 height:16 align:#left
	edittext 'edt_building_name' "" pos:[96,24] width:548 height:16 align:#left  text:"lh_08_family_house_a_v1"
	checkbox 'chk48' "" pos:[100,124] width:23 height:20 enabled:true checked:true align:#left
	checkbox 'chk49' "" pos:[100,148] width:23 height:20 enabled:true checked:true align:#left
)
createDialog mcAssetGeneratorDialog