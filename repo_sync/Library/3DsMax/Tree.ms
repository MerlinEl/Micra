function XCHtree : create tree structure from disc
	$path   :  path
	$level  :  kind of tree image
*******************************************************/
function XCHtree2($parent, $level) {
	global $dircount, $dirarr, $dirarrlvl, $dirarrparent, $dirarrpath;
	
	$res = MySQL_Query("SELECT * FROM tree WHERE parent=$parent ORDER BY name");
	
	if (!$res || !MySQL_Num_Rows($res)) return;

	$dirs = array();
	$ids = array();
	while ($arr = MySQL_Fetch_Array($res)) {
		$dirs[] = $arr["name"];
		$ids[] = $arr["id_tree"];
	}

	foreach ($dirs as $key=>$name) {
		$dirarr[$dircount] = $name;
		if ($key < count($dirs) - 1) {
			$type = "0";
			$type2 = "|";
		} else {
			$type = "1";
			$type2 = " ";
		}
		$dirarrlvl[$dircount] = $level.$type;
		$dirarrparent[$dircount] = $parent;
		$dirarrpath[$dircount] = $path.$name."/";
		$dircount++;
		XCHtree2($ids[$key], $level.$type2);
	}
}

$dircount = 0;
$dirarr = array();
$dirarrlvl = array();
$dirarrparent = array();
$dirarrpath = array();

XCHTree2(-1, "");