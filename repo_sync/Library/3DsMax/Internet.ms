shellLaunch "http://www.cgsociety.com/" ""
start http://www.cgosociety.com/ [parameters]

rollout WebTest "" width:162 height:49
    (
    	button btn_site "interwebulator" pos:[5,5] width:151 height:38
    	
    		on btn_site pressed do
    		(
    			process=dotnetclass "System.Diagnostics.Process"
    			process.start "http://www.dimensao3.com/al"
  			process.start "http://www.lonerobot.com/dotnetarticles.html"
  			process.start "http://www.tech-artists.org"
    		)
    )
    createdialog Webtest