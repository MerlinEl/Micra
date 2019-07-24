

var theRenderer = new Array ("Scanline", "VRay Advanced", "Brazil r/s 1 (Default)", "Brazil r/s 2 (Default)", "MR Fast SSS");
var theLayerNames = new Array();
theLayerNames[0] = new Array("Ambient Color", "Diffuse Color", "Specular Color", "Specular Level", "Glossiness", "Self-Illumination", "Opacity", "Filter Color", "Bump", "Reflection", "Refraction", "Displacement")
theLayerNames[1] = new Array("Diffuse", "Reflect", "HGlossiness", "RGlossiness", "Fresnel IOR", "Refract", "Glossiness", "IOR", "Translucent", "Bump", "Displace", "Opacity", "Environment")
theLayerNames[2] = new Array("Color (Cs)", "Opacity (Os)", "Extra Light", "Diffusion", "Bump", "Displacement", "Environment", "Ambient","Luminosity","Ka","Kd","Kl","Reflect","Kr","IOR","Highlight Color","Spec Level","Spec Gloss","Soften","Gain")
theLayerNames[3] = new Array("Color (Cs)", "Opacity (Os)", "Extra Light", "Diffusion", "Bump", "Displacement", "Environment", "Ambient","Luminosity","Ka","Kd","Kl","Reflectivity","Reflection Tint","Kr","IOR","Specular Color","Spec Level","Spec Gloss","Soften","Gain")
theLayerNames[4] = new Array("Bump", "Ambient", "Overall Diffuse Color", "Unscattered Diffuse Color", "Unscattered Diffuse Weight", "Front Surface Scatter Color", "Front Surface Scatter Weight", "Front Surface Scatter Radius", "Back Surface Scatter Color", "Back Surface Scatter Weight", "Back Surface Scatter Radius", "Back Surface Scatter Depth", "Specular Color", "Shininess", "Scale Conversion Falloff", "Falloff Strenght");
var theSizesLables = new Array ("64x64", "128x128", "256x256", "512x512", "1024x1024", "2048x2048", "4096x4096", "Custom ...")
var theSizes = new Array(64,128,256, 512, 1024, 2048,4096)
function createDocument () {
	if (parseInt(win.panel1.dropdown1.selection) == theSizesLables.length - 1){
		theWidth = parseInt(win.panel1.custom_width.text)
		theHeight = parseInt(win.panel1.custom_height.text)
	}else{
		theWidth = theHeight = theSizes[parseInt(win.panel1.dropdown1.selection)]
	} 
	theDoc = app.documents.add(new UnitValue (theWidth, "px"), new UnitValue (theHeight, "px"), 72)
	theLayers = theLayerNames[parseInt(win.pnl_renderer.renderer_drp.selection)]
	for (i = theLayers.length - 1; i >= 0; i--) {
		theLayer = theDoc.artLayers.add()
		theLayer.name = theLayers[i]
	}
}


function init(dlg) {
	for (i=0;i<theRenderer.length;i++){
	 dlg.pnl_renderer.renderer_drp.add("item", theRenderer[i])
	}
	dlg.pnl_renderer.renderer_drp.selection = [0]
	for (i=0;i<theSizesLables.length;i++){
	 dlg.panel1.dropdown1.add("item", theSizesLables[i])
	}
	dlg.panel1.dropdown1.onChange = function () {
		if (parseInt(this.selection) == theSizesLables.length - 1) {
			dlg.panel1.custom_width.enabled = dlg.panel1.custom_height.enabled = dlg.panel1.checkbox0.enabled = true 
			if (dlg.panel1.checkbox0.value){
				dlg.panel1.custom_height.enabled = true
			}
		}else{
			dlg.panel1.custom_width.enabled = dlg.panel1.custom_height.enabled =  dlg.panel1.checkbox0.enabled = false 	
		}
	}
	dlg.panel1.dropdown1.selection = 3
	dlg.panel1.custom_width.enabled = dlg.panel1.custom_height.enabled =  dlg.panel1.checkbox0.enabled =false

	dlg.panel1.custom_width.onChanging = function () {
		dlg.panel1.custom_width.text = parseInt(this.text)
		if (dlg.panel1.checkbox0.value){
			dlg.panel1.custom_height.text = this.text
		}
	}
	dlg.panel1.custom_height.onChanging = function () {
		dlg.panel1.custom_height.text = parseInt(this.text)
	}
	dlg.panel1.checkbox0.onClick = function () {
	 if(this.value){
	  dlg.panel1.custom_height.enabled = false
	 }else{
	  dlg.panel1.custom_height.enabled = true
	 }
	}
	dlg.button0.onClick = function () {
		win.close()
	}
	dlg.button1.onClick = function () {
		createDocument()
		win.close()
	}
}

var res = "dialog{text:'Script Interface',bounds:[100,100,330,370],\
		pnl_renderer:Panel{bounds:[10,10,220,70] , text:'Renderer  ' ,properties:{borderStyle:'etched',su1PanelCoordinates:true},\
			renderer_drp:DropDownList{bounds:[10,20,200,35]}\
		},\
		panel1:Panel{bounds:[10,90,220,230] , text:'Document Size  ' ,properties:{borderStyle:'etched',su1PanelCoordinates:true},\
			dropdown1:DropDownList{bounds:[100,20,200,35]},\
			statictext0:StaticText{bounds:[10,20,60,37] , text:'Presets  ' ,properties:{scrolling:false,multiline:false}},\
			statictext1:StaticText{bounds:[10,50,90,67] , text:'Custom Width  ' ,properties:{scrolling:false,multiline:false}},\
			statictext2:StaticText{bounds:[10,70,90,87] , text:'Custom Height  ' ,properties:{scrolling:false,multiline:false}},\
			custom_width:EditText{bounds:[100,50,201,66] , text:'512 ' ,properties:{multiline:false,noecho:false,readonly:false}},\
			custom_height:EditText{bounds:[100,70,201,86] , text:'512' ,properties:{multiline:false,noecho:false,readonly:false}},\
			checkbox0:Checkbox{bounds:[100,100,171,121] , text:'Lock Values' }\
		},\
		button0:Button{bounds:[10,240,100,261] , text:'close' },\
		button1:Button{bounds:[120,240,220,260] , text:'create' }\
};"
var win = new Window (res);
win.center();
init(win);
win.show();
