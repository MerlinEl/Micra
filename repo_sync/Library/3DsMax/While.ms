while not subobjectlevel < 1 do if subobjectlevel < 1 then 
print "end" 
exit



/*
x=10
while x>0 do print (x-=1)
*/

/*
--This script will print the mouse values 
--while you move the mouse inside the ListView control
rollout test "Test" 
( 
activeXControl lv "MSComctlLib.ListViewCtrl" height:100 width:100
on lv MouseMove Button Shift x y do 
format "Button: %, Shift: %, xy: %,%\n" Button Shift x y
)
createDialog test
*/