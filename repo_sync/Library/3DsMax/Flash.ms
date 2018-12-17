--AS3 snippet for reading flashVars


var txt:TextField = new TextField();
addChild(txt);
var obj:Object = (LoaderInfo(this.root.loaderInfo).parameters);
var s:String;
for (s in obj ){
	txt.appendText(s+"="+String(obj[s])+"n");
}



--maxscript snippet for sending flashVars


rollout myRollout "renderhjs"( 
	activeXControl flash "{D27CDB6E-AE6D-11CF-96B8-444553540000}" pos:[0,0] width:96 height:220  align:#left
	on myRollout open do( 
		swf = "c:gui.swf";
		flash.movie = swf
		flash.movie = swf -- need to load 2nd time sometimes
		flash.FlashVars = "var1=banana";
		flash.FlashVars = "val2=star wars";
	)
)
CreateDialog myRollout 96 220 pos:[320,100];