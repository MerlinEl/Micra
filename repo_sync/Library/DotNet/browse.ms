[void][reflection.assembly]::LoadWithPartialName
("System.Windows.Forms")
$form = new-object Windows.Forms.Form
$browse = new-object windows.Forms.OpenFileDialog
$browse.text = "..."

$button1 = New-Object system.Windows.Forms.Button
$button1.Text = "Choose...."
$button1.Add_Click({$browse.ShowDialog()})
$button1.left = 20
$button1.top = 20

$form.controls.add($button1)
$form.ShowDialog()


If you want to choose a Folder you should use the FolderBrowserDialog.
However i had problems with this in a Poweshell V2 CTP3 Environment -
it only runs in the ISE.

Example:

$button = $browse = $form = 0
[void][reflection.assembly]::LoadWithPartialName
("System.Windows.Forms")
$browse = new-object system.windows.Forms.FolderBrowserDialog
$browse.RootFolder = [System.Environment+SpecialFolder]'MyComputer'
$browse.ShowNewFolderButton = $false
$browse.selectedPath = "C:\"
$browse.Description = "Choose a directory"

$button1 = New-Object system.Windows.Forms.Button
$button1.Text = "Choose Directory"
$button1.Add_Click({$browse.ShowDialog()})
$button1.left = 20
$button1.top = 20

$form = New-Object system.windows.forms.Form
$form.controls.add($button1)
$form.ShowDialog()
$form.Dispose()

$browse.SelectedPath