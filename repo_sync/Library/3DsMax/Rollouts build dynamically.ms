rci = rolloutCreator "myRollout" "My Rollout"
rci.begin()
rci.addControl #button #btn_d "Delo" 
rci.addControl #checkbox #myCheckbox "chk"
rci.addControl #checkbox #myOtherCheckbox "chk"
rci.addControl #spinner #spn_d "spin" 
rci.addHandler #btn_d #pressed codeStr:"MessageBox @Hey@" filter:on
rci.addHandler #myCheckbox #changed paramStr:"val" codeStr:"myOtherCheckbox.state = not value"
rci.end()
createDialog rci

rfTest = rolloutCreator "rfTestN" "rfTestC"
-- Start creating the rollout
rfTest.begin()
rfTest.addControl #button #myButton "My Button" -- add a button
rfTest.addHandler #myButton #pressed filter:on codeStr:"MessageBox @Look to the \@Light\@ thing@" 
rfTest.end()
createDialog rfTest.def


(
	local strRollout = ""
	strRollout += "rollout dTest \"Build Rollouts Dynamically\" width:162 height:300 \n(\n"
	for i=1 to 14 do (strRollout += "\tspinner spn_" + (i as string) + " \"Spin_"+(i as string)+":\"\n")
	strRollout += ")\nCreateDialog dTest"
	execute strRollout
)




rci = rolloutCreator "myRollout" "My Rollout"
rci.begin()
rci.addControl #button #myButton "My Button"
rci.addHandler #myButton #pressed filter:on codeStr:"MessageBox @Isn't this cool@ title:@Wow@"
createDialog (rci.end())





rfTest = rolloutCreator "rfTestN" "rfTestC"
-- Start creating the rollout
rfTest.begin()
rfTest.addControl #button #myButton "My Button" -- add a button
rfTest.addHandler #myButton #pressed filter:on codeStr:"MessageBox @Look to the \@Light\@ thing@" 
rfTest.end()
createDialog rfTest.def