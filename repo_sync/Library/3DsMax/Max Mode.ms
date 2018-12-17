local vn=maxVersion()
if vn[1]>=7000 do

max create mode
max modify mode
max hierarchy mode
max motion mode
max display mode
max utility mode
	
#Struct:modPanel(
  setPinStack:<fn>; Public,
  isPinStackEnabled:<fn>; Public,
  setCurrentObject:<fn>; Public,
  addModToSelection:<fn>; Public,
  getModifierIndex:<fn>; Public,
  validModifier:<fn>; Public,
  getPinStack:<fn>; Public,
  getCurrentObject:<fn>; Public)
  
  
  modpanel.getCurrentObject()