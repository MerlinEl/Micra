--------------------------------------------------------------------------------
/* mcGlobal by Orien 2020 */
--------------------------------------------------------------------------------
-----------------------
--Global Declarations-- 
-----------------------
Global TypeBox


-----------------------
--Global Functions-- 
-----------------------
fn TypeBox msg = (

	local rdia = dotNetObject "MaxCustomControls.RenameInstanceDialog" ""
	rdia.text = msg
	local DialogResult = rdia.Showmodal()
	local OK_CLASS = (dotnetclass "System.Windows.Forms.DialogResult").OK
	if dotnet.compareenums rdia.DialogResult OK_CLASS and rdia.InstanceName.count != 0 then (
		rdia.InstanceName 
	) else undefined
)
