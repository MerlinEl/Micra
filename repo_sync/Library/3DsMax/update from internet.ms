(
 clearListener()
 global test
 try(destroydialog test) catch()
 local script_ver = 0.1
 local script_name = "webtest v."
 local script_ver_text = script_name + script_ver as string
  
  rollout test "Web Update Test"
  (
   label about1 ""
   hyperLink newver_download "Update do not exist" align:#center color:(color 0 0 0) hoverColor:(color 40 177 255) visitedColor:(color 0 0 0)
   button update_check_btn "Update Check" align:#center border:false width:111 height:16
   activeXControl check_web "Microsoft.XMLHTTP" setupEvents:false releaseOnClose:true height:0
    
    fn update_check = (
      check_web.open "GET" "http://???/????.php" false
      check_web.setrequestheader "If-Modified-Since" "Sat, 1 Jan 1900 00:00:00 GMT"
      check_web.send()
      webread = (execute (check_web.responsetext))
      if webread[1] > script_ver then (
        newver_download.enabled = true
        newver_download.text = "N Ver:" + webread[1] as string + " Update!"
        newver_download.address = webread[2]
        newver_download.color= (color 7 185 211)        
      )
      if webread[1] <= script_ver then (
        newver_download.enabled = false
        newver_download.text = "Update do not exist"
        newver_download.color= (color 0 0 0)
      )
    )
   on test open do (
     about1.text = script_ver_text
     update_check()
   )
   on update_check_btn pressed do update_check()
  )
createdialog  test 300 200