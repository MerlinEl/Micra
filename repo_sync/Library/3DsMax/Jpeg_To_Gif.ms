		if files.count != 0 do 
		(
			--convert jpg to giff
			exe = (app_path +"jpg2gif.exe")
			cmd = " -k -a *.jpg"
			format "exe:%\tcmd:%\n" exe cmd
			ShellLaunch exe cmd
			--compile gif to one
			exe = (app_path +"gifsicle.exe")
			cmd = (" -d="+fps+"  "+temp_save_path+"*.* > "+edt_path.text)
			format "exe:%\tcmd:%\n" exe cmd
			ShellLaunch exe cmd
			--delete old gif files
			local gif_files = getFiles (temp_save_path + "\\*.gif")
			print gif_files.count
			if gif_files.count != 0 do for f in gif_files do deleteFile f
		)
		--jpg2gif -k -a *.jpg
		--gifsicle -d=25 C:\temp\grab\*.* > C:\temp\grab\Anim\anim.gif