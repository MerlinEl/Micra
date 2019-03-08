macroscript stereocamera category:"Alpay" tooltip:"StCameraCreator v0.3"
(
	fn cameralar aciklik hedef =
	(
		if selection.count ==1  then
		(
			nokta=point() --açikligi kontrol için -- to control the spacing
			nokta.size=aciklik
			nokta.pos=$.pos
			nokta.parent=$
			nokta.name="aciklik_spacing"
			
			
			if (classof $==targetcamera) and ($.target!=undefined) then
			(
				ksag=instance $
				ksol=instance $

				ksag.lookat=$.target
				ksol.lookat=$.target
				
			)
			else
			(
				if (classof $==freecamera) then
				(
					ksag=instance $
					ksol=instance $
				)
				else
				(
					messagebox "Please Select one Camera \n Lutfen Bir Kamera Secin" 
				)
			)
			ksag.name="sag_right"
			ksol.name="sol_left"
			
			ksag.pos=ksol.pos=$.pos
			coordsys local move ksag [(aciklik/2),0,0]
			coordsys local move ksag [-(aciklik/2),0,0]
			
			ksag.parent=$
			ksol.parent=$
			
			
			poscontsag=float_script()
			poscontsag.script="dependson $aciklik_spacing \n coordsys $"+$.name+"  $"+$.name+".position.x+($aciklik_spacing.size/2)"
			
			poscontsol=float_script()
			poscontsol.script="dependson $aciklik_spacing \n coordsys $"+$.name+" $"+$.name+".position.x-($aciklik_spacing.size/2)"
			
			
			
			ksag.pos.x_position.controller=poscontsag
			ksol.pos.x_position.controller=poscontsol
			
		)
		else
		(
			messagebox "Please Select one Camera or Your camera's target may have been deleted \n Lutfen Bir Kamera Secin ya da Kameranizin targeti silinmis olabilir."
		)
	)
	
	---------------------------------------------------------------------------------------------------------
	
	rollout StereoCamera "StereoCamera v0.3"
	(
		spinner aciklik "Spacing-Açiklik" range:[0,1000,7] tooltip:"This can be controlled by the point helper's Size."
		button create "CREATE!" width:100 pos:[0,22]
		pickbutton ooi "Obj of int" autodisplay:true width:200 height:22 pos:[0,44]
		button del "Delete" width:100 pos:[100,22]
		button rend "RenderStereo" width:200 height:40 pos:[0,88]
		button yardim "Yardim" width:100 pos:[0,66]
		button help "Help" width:100 pos:[100,66]
		button sel "Select point helper" width:200 pos:[0,132]
				
		label hakkimda " By Alpay Küçük" style_sunkenedge:true width:80 height:17 pos:[60,154]
		
		on del pressed do 
		(
			if $sag_right!=undefined and $sol_left!=undefined and $aciklik_spacing!=undefined do
			(
				delete $sag_right
				delete $sol_left	
				delete $aciklik_spacing
				for o in cameras do
				(
					if classof o == targetcamera do
					(
						if o.target==undefined do
						(
							o.type=#free
							o.type=#target
						)
					)
					
				)
			)
		)
		
		
		on create pressed do
		(
			if ooi.object!=undefined  then
			(
				hed=ooi.object
				d=distance hed $
				print d
				print ooi.object
				$.targetdistance=d
			)
			else
			(
				d=$.targetdistance
			)
			cameralar aciklik.value d
		)
		
		on rend pressed do
		(
			if $sag_right!=undefined and $sol_left!=undefined do
			(
				render camera:$sag_right
				render camera:$sol_left
			)
		)
		
		on yardim pressed do
		(
			messagebox "-Ana kameranizi seçin,\nkameralar arasi açikligi ayarlayin\nve \"Create\" dügmesine basin.\n\n-Kameralar arasi açikligi\nsonradan point helperin \"Size\" degerini\ndegistirerek de ayarlayabilirsiniz.\n\n-Viewportta hangi viewin seçili\nolmasindan bagimsiz olarak\n\"Render\" dügmesine basarak iki görüntüyü\nrender edebilirsiniz.\n\n-\"Delete\" dügmesi, sonradan olusturulmus\nbütün kamera ve point helperlari\nsiler.\n\n -\"Obj of int\" ile sececeginiz obje ile kamera arasindaki\nuzaklik, kameranin target distance\ndegerine atanir boylece secilenobje\ngörüntüde az kayar. " beep:false title:"Yardim"
		)
		
		on help pressed do
		(
			messagebox "-Select your base camera,\nset the distance between cameras\nand press \" Create\" button.\n\n-Later you can adjust the spacing\nbetween stereo cameras by\nchanging the point helper's \"Size\" property.\n\n-You can render from both cameras\nby clicking the \"Render\" button\n regardless from which view\nor camera is active in viewport.\n\n-\"Delete\" button deletes all cameras\nandpoint helpers created laterly.\n\n-The distance between the object you pick by\n\"Obj of int\" button and camera\nis assigned to the camera's\ntarget distance so that\nthe object slides less in views." beep:false title:"Help"
		)
		
		on sel pressed do
		(
			if $aciklik_spacing!=undefined do(select $aciklik_spacing)
		)
		
	)
	
	
	
	createDialog StereoCamera width:200

	
	
	

	
	
	
	
	
	
	
)




				