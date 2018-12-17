--Actually there is another undocumented method of adding items to the QAT toolbar:

fn QATaddItem MacroScriptName Category =
(

	maintoolbar_file = pathConfig.removePathLeaf((symbolicPaths.getPathVa  lue "$userscripts")) + "\\ui\\MaxStartUI.cui"

	--First save our current CUI file as the MaxStartUI.cui
	deleteFile maintoolbar_file
	cui.saveConfigAs maintoolbar_file

	--Read Current Item count
	QATItemCount = getINISetting maintoolbar_file "QATItems" "QATItemCount"

	--Set value
	setINISetting maintoolbar_file "QATItems" ("Item" + QATItemCount) ("647397|" + MacroScriptName + "`" + Category)

	--Reload cui file
	cui.loadConfig maintoolbar_file
)

---This adds button to quick launch bar.

Autodesk.Windows.ToolBars.QuickAccessToolBarSource strip = ComponentManager.QuickAccessToolBar;
if (strip != null)
{
RibbonButton rb = new RibbonButton();
rb.Text = "test";
strip.AddStandardItem(rb);
rb.Description = "Desc";
rb.Image = GetIcon(theImage);
}






