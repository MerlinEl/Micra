#target photoshop

/*

// BEGIN__HARVEST_EXCEPTION_ZSTRING

<javascriptresource>
<name>Scripted Fill UI v 1.3</name>
<about>Written by Chuck Uebele 2012</about>
<category>fill</category>
</javascriptresource>

// END__HARVEST_EXCEPTION_ZSTRING

*/

/////////////////////////////////Notes//////////////////////////////////////////////////////////////////////////////////////////////////
/*
This UI contains mostly text boxes for the user to type in numbers.  There is a function that checks to make sure a valid number has been entered.
If you feel you want to expand the limits, you can change them by locating the UI control (it usual is close to a static text control that has the label) and changing the values of the function call as shown here:
function(){textToNum(Enter_Lower_Limit,Enter_Higher_Limit,this,'float',false)};
Just the first two numbers you would have to change.
*////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////Set unit preferences and store old ones
var oldPref = app.preferences.rulerUnits;
app.preferences.rulerUnits = Units.PIXELS;

///////////////////support files
var tempScript = new File(app.path +  "/presets/deco/TempFillScript.jsx" );//temp file that this script creates to run fill
var uiPref = new File(app.path +  "/presets/deco/fillScriptPref.xml" );//file for user preferences
var colorSample = new File(app.path + "/presets/scripts/fillScriptColorRef.jsx")//file that stores color reference samples - must have other script to create this one.
var bwSample = new File(app.path + "/presets/scripts/fillBWPoints.jsx");//file that stores BW reference samples - must have other script to create this one.
var refFile = new File(app.path + "/presets/scripts/refFile.xml");

///////////////////Script variables 
var scriptArray = new Array();//Array to hold all the lines of code for the temp script so that it can be looped through and written line by line.
var docRef

//rangeNumArray and divideNum are used to calculate and store how many passes and the script will make and what values to have it render a pattern for multiple passes.
var rangeNumArray = new Array();
var divideNum
var brickGp, crossGp, sprialGp, randGp, randBrdGp, symGp//define stacked groups for UI - less typing.
var minValTemp = 0;//min and max values for the passes to either render or not.
var maxValTemp = .3;
var seed2Temp = 1;//  Used to "randomize" the passes, but since it's seeded, it can repeat the pattern and fill in the gaps in the next pass.
var blendM;//holds which blend mode to be used.


//Two short vars: one an array an array that holds all the lines of code for the temp script.
//The other is a counter so that a line of code can be added and moved without having to renumber the array.
var a = new Array ();
var n = 0

//////////////////UI variables 
var dlg;//the UI dialog object
var dvar = new Object();//all UI vars are stored in this object, which will be transferred to the temp script.
var boxSize = [50,20];//size for the UI text boxes - once place to change them all.
var lftM = ['left','middle'];//basic alignment for controls on UI
var rtM = ['right','middle'];//right alignment for controls on UI
var fillT = ['fill','top'];//basic alignmement for UI groups
var update = false;//for turning off update notification of edittext boxes until all values are set from a preset
var reset = false;
var runProg = true;//used to make sure all the values are correct before closing the ui
//Arrays to hold values for dropdownlist in the UI
var scriptType = new Array('Brick','Cross Weave','Spiral','Random','Random Border','Symmetry');//types of scripts
var symPatList =new Array()
symPatList = ['0: line reflection','1: point reflection, frameZero','2: rotation symmetry with 4 elements around the center',
    '3: translation symmetry','4: glide reflection','-','5: dilatation symmetry','6: dilative rotation symmetry','7: a different dilative rotation  symmetry',
    '8: infinite dilative rotation symmetry','-','9:  translation frieze','10: glide reflection frieze','11: translation line reflection freeze',
    '12: translation mirror reflection freeze','13: translation point reflection freeze','14: translation double reflection freeze',
    '15: glide reflection rotation freeze','-','16: wallpaperP1 symmetry','17: wallpaperP2 symmetry','18: wallpaperPM symmetry',
    '19: wallpaperPG symmetry','20: wallpaperPMM symmetry','21: wallpaperCM symmetry','22: wallpaperPMG symmetry',
    '23: wallpaperPGG symmetry','24: wallpaperCMM symmetry','25: wallpaperP4 symmetry','26: wallpaperP4M symmetry',
    '27: wallpaperP4G symmetry','28: wallpaperP3 symmetry','29: wallpaperP3M1 symmetry','30: wallpaperP31M symmetry',
    '31: wallpaperP6 symmetry','32: wallpaperP6M symmetry'];
var symPatSel = 32;//the default symmetry pattern and var to use in rest of script for reference to the patterns.

var blendList = new Array()
blendList = ['Normal','Dissolve','Behind','Clear','-','Darken','Multiply','Color Burn','Linear Burn','Darker Color','-','Lighten','Screen','Color Dodge',
    'Linear Dodge (Add)','Lighter Color','-','Overlay','Soft Light','Hard Light','Vivid Light','Linear Light', 'Pin Light','Hard Mix','-','Difference', 'Exclusion',
    'Subtract','Divide','-','Hue','Saturation','Color','Luminosity'];
var patternBlendList = new Array()
patternBlendList = ['Normal','Dissolve','-','Darken','Multiply','Color Burn','Linear Burn','Darker Color','-','Lighten','Screen','Color Dodge',
    'Linear Dodge (Add)','Lighter Color','-','Overlay','Soft Light','Hard Light','Vivid Light','Linear Light', 'Pin Light','Hard Mix','-','Difference', 'Exclusion',
    'Subtract','Divide','-','Hue','Saturation','Color','Luminosity']
var randRotationList = new Array('Random Rotation','No Rotation','Custom Angle','Use Reference File');
var randBdrRotationList = new Array('Random Rotation','No Rotation','Custom Angle');
var rLimit;//multiplication factor to limit pattern rotation to either 360 or 180 degrees. 
 
var presetList = new Array(  );//Blank array to be populated with the users preferences stored in an XML file
var colorsA = new Array();//Array to hold color values of a reference image that are produced by another script.  Used with the brick fill.
var bwA = new Array()    ;//Array to hold b&w values of a reference image that are produced by another script.  Used with random script to produce shaped fills from layers

///////////Preference and XML vars
var startNodes = new XML('<root><presets><preset presetName ="Current Default"/></presets></root>');//creates a start for addin info to the XML preference file.
var prefXML = new XML();// the actual XML file that holds the preferences until written to a file.
var refXML = new XML();// the actual XML file that holds the preferences until written to a file.
var saveName;//Name for the saved preset



///////////////Check to see if document is open
app.documents.length>0 ? runProgram() : alert('There are no open files');


function runProgram(){
    docRef = activeDocument
    if(uiPref.exists){prefXML = new XML(readXMLFile(uiPref))};// see if a preference file exists and load it.
    ui()

    };//end function runProgram

function ui(){
    dlg = new Window('dialog','Scripted Fill')
    dlg.spacing = 7
    dlg.alignChildren = ['fill','top'];

    dlg.scriptGp = dlg.add('group');
        dlg.scriptGp.orientation = 'row';
        dlg.scriptGp.alignment = fillT;
        dlg.scriptGp.alignchilden = lftM;
        
        dvar.scriptDbx = dlg.scriptGp.add('dropdownlist',undefined,scriptType);dvar.scriptDbx.name = 'scriptDbx';
            dvar.scriptDbx.selection = 0;
            dvar.scriptDbx.alignment = lftM;
            dvar.scriptDbx.title = '   Script';
            dvar.scriptDbx.titleLayout ={alignment: ['right','center']}
            dvar.scriptDbx.onChange = function() {enableUI()};
            
        dlg.scriptGp.writtenBy = dlg.scriptGp.add('statictext',undefined,'Written by Chuck Uebele\nCopyright \u00A9 2012 Chuck Uebele, all rights reserved, V1.3 2018',{multiline: true});
            dlg.scriptGp.writtenBy.alignment = rtM;
            dlg.scriptGp.writtenBy.justify = 'right';
            dlg.scriptGp.writtenBy.size = [300,33]
            
            
        ///////////////////////Create tabbed panel ////////////////////////////////////////////////////////////////////////////////////////
        dlg.tabPn = dlg.add ('tabbedpanel',undefined);     
            dlg.tabPn.alignment = fillT;    
            
                                                   
            ////////////////////////Stacked Script Tab/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            dlg.tabPn.scriptTab = dlg.tabPn.add('tab',undefined,dvar.scriptDbx.selection.text + ' Settings');
                dlg.tabPn.scriptTab.alignChildren = ['fill','top'];  
                dlg.tabPn.scriptTab.orientation = 'stack';                
                
                ///////////////////Brick//////////////////////////////////////////////////////////
                brickGp = dlg.tabPn.scriptTab.add('group');
                    brickGp.orientation = 'column';
                    brickGp.alignChildren = ['fill','top'];
                    parseInt(dvar.scriptDbx.selection) == 0 ? brickGp.visible = true : brickGp.visible = false;

                    brickGp.offsetGP = brickGp.add('group');
                        brickGp.offsetGP.orientation = 'row';
                        brickGp.offsetGP.alignChildren = ['left','middle'];
                        
                        dvar.brickOffset = brickGp.offsetGP.add('edittext',undefined,.5);dvar.brickOffset.name = 'brickOffset'
                            dvar.brickOffset.size = boxSize;
                            dvar.brickOffset.onChange = function(){textToNum(0,1,this,'float',false)};
                        
                        brickGp.offsetGP.offsetStxt = brickGp.offsetGP.add('statictext',undefined,'Offset (0~1)');
                        
                    dvar.sizeJitCbx = brickGp.add('checkbox',undefined,'Size Jitter');dvar.sizeJitCbx.name = 'sizeJitCbx'
 
                    brickGp.fileLine = brickGp.add('panel',undefined,undefined, {borderStyle: 'sunken'});
                        brickGp.fileLine.alignment = ['fill','top'];
                        
                    brickGp.jitInfo = brickGp.add('statictext',undefined,'The angle jitter uses two inputs.  The angle sets the angle of the pattern,\nand the Angle Range sets the span of the jitter.' +
                        '\nNormally, you want to set the range to twice the amount of the angle.',{multiline:true});
                        brickGp.jitInfo.preferredSize = [400,40];
                        
                        dvar.angleJitCbx = brickGp.add('checkbox',undefined,'Angle Jitter');dvar.angleJitCbx.name = 'angleJitCbx';
                        dvar.angleJitCbx.onClick = function(){enableUI()};
                            dvar.angleJitCbx.value = true;                        
                        
                    brickGp.angleJitGp = brickGp.add('group');
                        brickGp.angleJitGp.orientation = 'row';
                        brickGp.angleJitGp.alignChildren = ['left','middle'];
                        brickGp.angleJitGp.alignment = ['fill','top'];
                        
                         dvar.angleEtxt = brickGp.angleJitGp.add('edittext',undefined,'-4');dvar.angleEtxt.name = 'angleEtxt';
                            dvar.angleEtxt.size = boxSize;
                            dvar.angleEtxt.onChange = function(){textToNum(-180,180,this,'float',false)};
                            
                       brickGp.angleJitGp.angleStxt = brickGp.angleJitGp.add('statictext',undefined,'Pattern Angle (-180~180)');
                            
                            
                        dvar.angleAmtEtxt = brickGp.angleJitGp.add('edittext',undefined,'7.5');dvar.angleAmtEtxt.name = 'angleAmtEtxt';
                            dvar.angleAmtEtxt.size = boxSize;
                            dvar.angleAmtEtxt.alignment = ['middle','middle'];
                            dvar.angleAmtEtxt.onChange = function(){textToNum(0,30,this,'float',false)};                          

                        brickGp.angleJitGp.angleAmtStxt = brickGp.angleJitGp.add('statictext',undefined,' Jitter Range (0~30)');
                        

                ///////////////////Cross Weave//////////////////////////////////////////////////////////
                crossGp = dlg.tabPn.scriptTab.add('group');
                    crossGp.orientation = 'column';
                    crossGp.alignChildren = ['left','top'];    
                    parseInt(dvar.scriptDbx.selection) == 1 ? crossGp.visible = true : crossGp.visible = false;
                    
                    crossGp.angGp = crossGp.add('group');
                        crossGp.angGp.alignChildren =lftM;
                        crossGp.angGp.orientation = 'row';
                        
                        dvar.crossAngle = crossGp.angGp.add('edittext',undefined,0);dvar.crossAngle.name = 'crossAngle';
                            dvar.crossAngle.size = boxSize;
                            dvar.crossAngle.onChange = function(){textToNum(0,360,this,'int',false)};
                            
                            crossGp.angGp.angStxt = crossGp.angGp.add('statictext',undefined,'Weave Angle');
                            
                            dvar.crossRand = crossGp.add('checkbox',undefined,'Random rotation to pattern');dvar.crossRand.name = 'crossRand'
                    
                ///////////////////spiral//////////////////////////////////////////////////////////
                sprialGp = dlg.tabPn.scriptTab.add('group');
                    sprialGp.orientation = 'column';
                    sprialGp.alignChildren = ['left','top'];    
                    parseInt(dvar.scriptDbx.selection) == 2 ? sprialGp.visible = true : sprialGp.visible = false;
                    
                    //===================================
                    sprialGp.offsetGp = sprialGp.add('group');
                        sprialGp.offsetGp.orientation = 'row';
                        sprialGp.offsetGp.alignChildren = lftM;
                        
                        
                        dvar.spiralOffset = sprialGp.offsetGp.add('edittext',undefined,0);dvar.spiralOffset.name = 'spiralOffset';
                            dvar.spiralOffset.size = boxSize;
                            dvar.spiralOffset.helpTip = 'Offset in pixels between two rings of the spiral'
                            dvar.spiralOffset.onChange = function(){textToNum(0,100,this,'float',false)};
                            
                        sprialGp.offsetGp.offsetStxt  =sprialGp.offsetGp.add('statictext',undefined,'Offset (0~100)');
                        
                    //============================================
                    sprialGp.patAngGp = sprialGp.add('group');
                        sprialGp.patAngGp.orientation = 'row';
                        sprialGp.patAngGp.alignChildren = lftM;                    
                        
                        dvar.spiralPatAngle = sprialGp.patAngGp.add('edittext',undefined,0);dvar.spiralPatAngle.name = 'spiralPatAngle';
                            dvar.spiralPatAngle.size = boxSize;
                            dvar.spiralPatAngle.helpTip = 'rotates each pattern at this relative angle'
                            dvar.spiralPatAngle.onChange = function(){textToNum(-180,180,this,'float',false)};
                            
                        sprialGp.patAngGp.patAngStxt  =sprialGp.patAngGp.add('statictext',undefined,'Patten Rotation (-180~180)');
                        
                    //===========================================
                    sprialGp.angFacGp = sprialGp.add('group');
                        sprialGp.angFacGp.orientation = 'row';
                        sprialGp.angFacGp.alignChildren = lftM;                                             
                           
                        dvar.angleFactor = sprialGp.angFacGp.add('edittext',undefined,1);dvar.angleFactor.name = 'angleFactor';
                            dvar.angleFactor.size = boxSize;
                            dvar.angleFactor.helpTip = 'Controls how close the elements are along the spiral. It is a multiplicative factor for the angle between subsequent segments.';
                            dvar.angleFactor.onChange = function(){textToNum(.3,1.5,this,'float',false)};
                            
                        sprialGp.angFacGp.aFactorStxt  =sprialGp.angFacGp.add('statictext',undefined,'Angle Factor (.3~1.5)');
                        
                    //===========================================
                    sprialGp.angGp = sprialGp.add('group');
                        sprialGp.angGp.orientation = 'row';
                        sprialGp.angGp.alignChildren = lftM;                       
                                            
                        dvar.spiralFillAngle = sprialGp.angGp.add('edittext',undefined,-90);dvar.spiralFillAngle.name = 'spiralFillAngle';
                            dvar.spiralFillAngle.size = boxSize;
                            dvar.spiralFillAngle.onChange = function(){textToNum(-180,0,this,'float',false)};
                            
                        sprialGp.angGp.offsetStxt  =sprialGp.angGp.add('statictext',undefined,'Opening in Sprial Center & Total rotation (-180~0)');
                        
                    
                ///////////////////Random//////////////////////////////////////////////////////////
                randGp = dlg.tabPn.scriptTab.add('group');
                    randGp.orientation = 'column';
                    randGp.alignChildren = ['left','top'];    
                    parseInt(dvar.scriptDbx.selection) == 2 ? randGp.visible = true : randGp.visible = false;
                    
                    randGp.densGp = randGp.add('group');
                        randGp.densGp.orientation = 'row';
                        randGp.densGp.alignChildren = lftM; 
                        randGp.densGp.alignment = ['fill','top'] 
                        
                        dvar.randDens = randGp.densGp.add('edittext',undefined,2);dvar.randDens.name = 'randDens';
                            dvar.randDens.size = boxSize;
                            var randDensMin = .1
                            var randDensMax = 15
                            var randFloat = 'float'
                            dvar.randDens.onChange = function(){if(update){textToNum(randDensMin,randDensMax,this,randFloat,false)}};
                            
                        randGp.densGp.dStxt = randGp.densGp.add('statictext',undefined,'Density (.1~15)');
                            randGp.densGp.dStxt.characters = 20
                        
                        dvar.randUseDens = randGp.densGp.add('radiobutton',undefined,'Use calculated density');dvar.randUseDens.name = 'randUseDens';
                            //dvar.randUseDens.alignment = ['center','middle'];
                            dvar.randUseDens.value = true;
                            dvar.randUseDens.helpTip = 'Uses a calculated value for the number of patterns for the fill.';
                            dvar.randUseDens.onClick = function(){enableUI()};
                            
                        dvar.randUseNum = randGp.densGp.add('radiobutton',undefined,'Use exact number');dvar.randUseNum.name = 'randUseNum';
                            dvar.randUseNum.helpTip = 'Enter exact number of patterns for fill';
                            dvar.randUseNum.onClick = function(){enableUI()};      
                            
                    randGp.scaleGp = randGp.add('group');
                        randGp.scaleGp.orientation = 'row';
                        randGp.scaleGp.alignChildren = lftM;
                        randGp.scaleGp.alignment = ['fill','top'];
                        
                        dvar.randMinScale = randGp.scaleGp.add('edittext',undefined,.3);dvar.randMinScale.name = 'randMinScale';
                            dvar.randMinScale.size = boxSize;
                            dvar.randMinScale.onChange = function(){textToNum(.1,3,this,'float',false)};
                        randGp.scaleGp.minStxt = randGp.scaleGp.add('statictext',undefined,'Min Scale Value (.1~3)');
                            
                        dvar.randMaxScale = randGp.scaleGp.add('edittext',undefined,1.5);dvar.randMaxScale.name = 'randMaxScale';
                            dvar.randMaxScale.size = boxSize;
                            dvar.randMaxScale.alignment = ['center','middle'];
                            dvar.randMaxScale.onChange = function(){textToNum(.1,3,this,'float',false)};  
                        randGp.scaleGp.maxStxt = randGp.scaleGp.add('statictext',undefined,'Max Scale Value (.1~3)');
                        
                    //=================================================
                    randGp.rotateGp = randGp.add('group');
                        randGp.rotateGp.orientation = 'row';
                        randGp.rotateGp.alignChildren = lftM;
                        randGp.rotateGp.alignment = ['fill','top'];   
                        
                        dvar.randRotateDbx = randGp.rotateGp.add('dropdownlist',undefined,randRotationList);dvar.randRotateDbx.name = 'randRotateDbx';
                        dvar.randRotateDbx.title = '   Pattern Rotation';
                        dvar.randRotateDbx.titleLayout =  {alignment: ['right','center']};
                        dvar.randRotateDbx.selection = 0;
                        
                        dvar.randCusAng = randGp.rotateGp.add('edittext',undefined,0);dvar.randCusAng.name = 'randCusAng';
                            dvar.randCusAng.size = boxSize; 
                            dvar.randCusAng.onChange = function(){textToNum(-180,180,this,'int',false)};  
                            randGp.rotateGp.custAngStxt = randGp.rotateGp.add('statictext',undefined,'Custom Angle (-180~180)');
                            randGp.rotateGp.custAngStxt.enabled = dvar.randCusAng.enabled = false;
                            
                        dvar.randAngJit = randGp.rotateGp.add('checkbox',undefined,'Angle Jitter');dvar.randAngJit.name = 'randAngJit';
                            dvar.randAngJit.alignment = rtM;
                            dvar.randAngJit.enabled = false;
                            
                            
                            dvar.randRotateDbx.onChange = function(){
                                dvar.randAngJit.enabled = true;
                                dvar.randCusAng.enabled = randGp.rotateGp.custAngStxt.enabled = false;
                                switch(parseInt(this.selection)){
                                    case 0:
                                        dvar.randAngJit.enabled = dvar.randAngJit.value = false;
                                        dvar.randCusAng.text = 0
                                        break;
                                    case 1:
                                        dvar.randCusAng.text = 0
                                        break;
                                    case 2:
                                        dvar.randCusAng.enabled = randGp.rotateGp.custAngStxt.enabled = true;
                                        break;                                        
                                    };//end switch
                                };//end randRotateDbx 
                            
                 ///////////////////Random Border//////////////////////////////////////////////////////////
                randBrdGp = dlg.tabPn.scriptTab.add('group');
                    randBrdGp.orientation = 'column';
                    randBrdGp.alignChildren = ['left','top'];    
                    parseInt(dvar.scriptDbx.selection) == 2 ? randBrdGp.visible = true : randBrdGp.visible = false;
                    
                    randBrdGp.typeGp = randBrdGp.add('group');
                        randBrdGp.typeGp.orientation = 'row';
                        randBrdGp.typeGp.alignChildren = lftM; 
                        randBrdGp.typeGp.alignment = ['fill','top']                     
                    
                        dvar.square = randBrdGp.typeGp.add('radiobutton',undefined,'Square');dvar.square.name = 'square'
                            dvar.square.value = true
                        dvar.oval = randBrdGp.typeGp.add('radiobutton',undefined,'oval');dvar.oval.name = 'oval'      
                         
                        dvar.bSize = randBrdGp.typeGp.add('edittext',undefined,.35);dvar.bSize.name = 'bSize';
                            dvar.bSize.size = boxSize;
                            dvar.bSize.text = 10
                            dvar.bSize.alignment = rtM
                            dvar.bSize.onChange = function(){ textToNum(.5,50,this,'float',false)};
                            
                        randBrdGp.typeGp.bSize = randBrdGp.typeGp.add('statictext',undefined,'Border size .5-50');

                    //====================================================
                    randBrdGp.densGp = randBrdGp.add('group');
                        randBrdGp.densGp.orientation = 'row';
                        randBrdGp.densGp.alignChildren = lftM; 
                        randBrdGp.densGp.alignment = ['fill','top'] 
                        
                        dvar.randBrdDens = randBrdGp.densGp.add('edittext',undefined,2);dvar.randBrdDens.name = 'randBrdDens';
                            dvar.randBrdDens.size = boxSize;
                            var randBrdDensMin = .1
                            var randBrdDensMax = 15
                            var randBrdFloat = 'float'
                            dvar.randBrdDens.onChange = function(){textToNum(randBrdDensMin,randBrdDensMax,this,randBrdFloat,false)};
                            
                        randBrdGp.densGp.dStxt = randBrdGp.densGp.add('statictext',undefined,'Density (.1~15)');
                            randBrdGp.densGp.dStxt.characters = 20
                        
                        dvar.randBrdUseDens = randBrdGp.densGp.add('radiobutton',undefined,'Use calculated density');dvar.randBrdUseDens.name = 'randBrdUseDens';
                            
                            dvar.randBrdUseDens.value = true;
                            dvar.randBrdUseDens.helpTip = 'Uses a calculated value for the number of patterns for the fill.';
                            dvar.randBrdUseDens.onClick = function(){enableUI()};
                            
                        dvar.randBrdUseNum = randBrdGp.densGp.add('radiobutton',undefined,'Use exact number');dvar.randBrdUseNum.name = 'randBrdUseNum';
                            dvar.randBrdUseNum.helpTip = 'Enter exact number of patterns for fill';
                            dvar.randBrdUseNum.onClick = function(){enableUI() };      
                            
                    randBrdGp.scaleGp = randBrdGp.add('group');
                        randBrdGp.scaleGp.orientation = 'row';
                        randBrdGp.scaleGp.alignChildren = lftM;
                        randBrdGp.scaleGp.alignment = ['fill','top'];
                        
                        dvar.randBdrMinScale = randBrdGp.scaleGp.add('edittext',undefined,.3);dvar.randBdrMinScale.name = 'randBdrMinScale';
                            dvar.randBdrMinScale.size = boxSize;
                            dvar.randBdrMinScale.onChange = function(){textToNum(.1,3,this,'float',false)};
                        randBrdGp.scaleGp.minStxt = randBrdGp.scaleGp.add('statictext',undefined,'Min Scale Value (.1~3)');
                            
                        dvar.randBdrMaxScale = randBrdGp.scaleGp.add('edittext',undefined,1.5);dvar.randBdrMaxScale.name = 'randBdrMaxScale';
                            dvar.randBdrMaxScale.size = boxSize;
                            dvar.randBdrMaxScale.alignment = ['center','middle'];
                            dvar.randBdrMaxScale.onChange = function(){textToNum(.1,3,this,'float',false)};  
                        randBrdGp.scaleGp.maxStxt = randBrdGp.scaleGp.add('statictext',undefined,'Max Scale Value (.1~3)');
                        
                    //=================================================
                    randBrdGp.rotateGp = randBrdGp.add('group');
                        randBrdGp.rotateGp.orientation = 'row';
                        randBrdGp.rotateGp.alignChildren = lftM;
                        randBrdGp.rotateGp.alignment = ['fill','top'];   
                        
                        dvar.randBrdRotateDbx = randBrdGp.rotateGp.add('dropdownlist',undefined,randBdrRotationList);dvar.randBrdRotateDbx.name = 'randBrdRotateDbx';
                        dvar.randBrdRotateDbx.title = '   Pattern Rotation';
                        dvar.randBrdRotateDbx.titleLayout =  {alignment: ['right','center']};
                        dvar.randBrdRotateDbx.selection = 0;
                        
                        dvar.randBrdCusAng = randBrdGp.rotateGp.add('edittext',undefined,0);dvar.randBrdCusAng.name = 'randBdrCusAng';
                            dvar.randBrdCusAng.size = boxSize; 
                            dvar.randBrdCusAng.onChange = function(){textToNum(-180,180,this,'int',false)};  
                            randBrdGp.rotateGp.custAngStxt = randBrdGp.rotateGp.add('statictext',undefined,'Custom Angle (-180~180)');
                            randBrdGp.rotateGp.custAngStxt.enabled = dvar.randBrdCusAng.enabled = false;
                            
                        dvar.randBrdAngJit = randBrdGp.rotateGp.add('checkbox',undefined,'Angle Jitter');dvar.randBrdAngJit.name = 'randBdrAngJit';
                            dvar.randBrdAngJit.alignment = rtM;
                            dvar.randBrdAngJit.enabled = false;
                            
                            
                            dvar.randBrdRotateDbx.onChange = function(){
                                dvar.randBrdAngJit.enabled = true;
                                dvar.randBrdCusAng.enabled = randBrdGp.rotateGp.custAngStxt.enabled = false;
                                switch(parseInt(this.selection)){
                                    case 0:
                                        dvar.randBrdAngJit.enabled = dvar.randBrdAngJit.value = false;
                                        dvar.randBrdCusAng.text = 0
                                        break;
                                    case 1:
                                        dvar.randBrdCusAng.text = 0
                                        break;
                                    case 2:
                                        dvar.randBrdCusAng.enabled = randBrdGp.rotateGp.custAngStxt.enabled = true;
                                        break;                                        
                                    };//end switch
                                };//end randRotateDbx 
                            
                    randBrdGp.randomGp = randBrdGp.add('group');
                    randBrdGp.randomGp.orientation = 'row';
                    randBrdGp.randomGp.alignChildren = lftM;
                    
                    dvar.useSeed = randBrdGp.randomGp.add('radiobutton',undefined,'Use seeded random numbers (repeatable)');dvar.useSeed.name = 'useSeed';
                    dvar.useMath = randBrdGp.randomGp.add('radiobutton',undefined,'Use totally randome numbers (non-repeatable)');dvar.useMath.name = 'useMath'
                        dvar.useMath.value = true;
                            
                     
                ///////////////////Symmetry//////////////////////////////////////////////////////////
                symGp = dlg.tabPn.scriptTab.add('group');
                    symGp.orientation = 'column';
                    symGp.alignChildren = ['left','top'];    
                    parseInt(dvar.scriptDbx.selection) == 2 ? symGp.visible = true : symGp.visible = false;

                    dvar.patternSelDbx = symGp.add('dropdownlist',undefined,symPatList);dvar.patternSelDbx.name = 'patternSelDbx';
                        dvar.patternSelDbx.selection = 35
                        dvar.patternSelDbx.title = '   Symmetry Patterns';
                        dvar.patternSelDbx.titleLayout = {alignment: ['right','center']};
                        
                     symGp.transGp = symGp.add('group');
                        symGp.transGp.orientation = 'row';
                        symGp.transGp.alignChildren = ['left','middle'];
                        symGp.transGp.alignment = ['fill','top'];
                        
                        
                        dvar.transX = symGp.transGp.add('edittext',undefined,.75);dvar.transX.name = 'transX';
                            dvar.transX.size = boxSize;
                            dvar.transX.onChange = function(){textToNum(-20,20,this,'float',false)};
                        symGp.transGp.transXStxt = symGp.transGp.add('statictext',undefined,'Pattern Translation X');
                            
                        
                       
                        dvar.transY = symGp.transGp.add('edittext',undefined,.75);dvar.transY.name = 'transY';
                            dvar.transY.size = boxSize;
                            dvar.transY.alignment = ['center','middle'];
                            dvar.transY.onChange = function(){textToNum(-20,20,this,'float',false)};  
                        symGp.transGp.transYStxt = symGp.transGp.add('statictext',undefined,'Pattern Translation Y');
                        
                    dvar.patternSelDbx.onChange = function(){
                        if(parseInt(this.selection)>4 && parseInt(this.selection)<10){symPatSel = parseInt(this.selection) -1}
                        else if(parseInt(this.selection)<5){symPatSel = parseInt(this.selection)}
                        else if(parseInt(this.selection)>10 && parseInt(this.selection)<18){symPatSel = parseInt(this.selection) -2}
                        else if(parseInt(this.selection)>18){symPatSel = parseInt(this.selection) - 3}
                        else{symPatSel = 32}   
                        };                            
                       
                        
                    
            /////////////////////////////End Stacked Panels////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            
            ////////////////////////Random and Passes Tab////////////////////////////////////////////////
            dlg.tabPn.passTab = dlg.tabPn.add('tab',undefined,'Passes');
                dlg.tabPn.passTab.alignChildren = ['left','top'];
                
                dvar.addLayer = dlg.tabPn.passTab.add('checkbox',undefined,'Add new layer for each pass');dvar.addLayer.name = 'addLayer';
                
                dlg.tabPn.passTab.passGp = dlg.tabPn.passTab.add('group');
                    
                        
                    dvar.pass = dlg.tabPn.passTab.passGp.add('edittext',undefined,1);dvar.pass.name = 'pass';
                        dvar.pass.size = boxSize;
                        dvar.pass.onChange = function(){textToNum(1,100,this,'int',false)};   
                    dlg.tabPn.passTab.passGp.passStxt = dlg.tabPn.passTab.passGp.add('statictext',undefined,'Number of Passes (1~100 Changes random pattern)');
                    
                dlg.tabPn.passTab.seedGp = dlg.tabPn.passTab.add('group');
                    dlg.tabPn.passTab.seedGp.orientation = 'row';
                     
                    dvar.seed = dlg.tabPn.passTab.seedGp.add('edittext',undefined,1);dvar.seed.name = 'seed';
                        dvar.seed.size = boxSize;
                        dvar.seed.helpTip = 'This affects the pattern that is selected for each pass.  Changing this number varies the pattern';
                        dvar.seed.onChange = function(){textToNum(.1,1,this,'float',false)};
                    dlg.tabPn.passTab.seedGp.seedStxt = dlg.tabPn.passTab.seedGp.add('statictext',undefined,'Seed start (.1~1 Changes random pattern for each pass)');
                        
            ////////////////////////Color and Brightness Tab////////////////////////////////////////////////
            dlg.tabPn.colorTab = dlg.tabPn.add('tab',undefined,'Color and Brightness');
                dlg.tabPn.colorTab.alignChildren = ['left','top'];
                
                dlg.tabPn.colorTab.jitGp = dlg.tabPn.colorTab.add('group');
                    dlg.tabPn.colorTab.jitGp.orientation = 'row';
                    dlg.tabPn.colorTab.jitGp.alignment = ['fill','top'];
                    dlg.tabPn.colorTab.jitGp.alignChildren = ['left','middle'];
                
                    
                    dvar.colorJit = dlg.tabPn.colorTab.jitGp.add('edittext',undefined,0);dvar.colorJit.name = 'colorJit'
                    dvar.colorJit.size = boxSize;
                    dvar.colorJit.onChange = function(){textToNum(0,1,this,'float',false)};
                    
                    dlg.tabPn.colorTab.jitGp.colorJitStxt = dlg.tabPn.colorTab.jitGp.add('statictext',undefined,'Color Jitter (0~1)');

                    
                        
                    dvar.brightJit = dlg.tabPn.colorTab.jitGp.add('edittext',undefined,0);dvar.brightJit.name = 'brightJit';
                    dvar.brightJit.size = boxSize;
                    dvar.brightJit.alignment = ['center','middle'];
                    dvar.brightJit.onChange = function(){textToNum(0,1,this,'float',false)};   

                    dlg.tabPn.colorTab.jitGp.brightStxt = dlg.tabPn.colorTab.jitGp.add('statictext',undefined,'Brightness Jitter (0~1)');
                    
                    //color fade===============================
                    dlg.tabPn.colorTab.fileLine = dlg.tabPn.colorTab.add('panel',undefined,undefined, {borderStyle: 'sunken'});
                        dlg.tabPn.colorTab.fileLine.alignment = ['fill','top'];
                        
                    dlg.tabPn.colorTab.infotxt = dlg.tabPn.colorTab.add('statictext',undefined,'Color fade work in CMYK. More color and density are applied as the number get lower.\nSetting the numbers very low (.01 or .001) help spread the fade over more of the fill.',{multiline:true})
                    dlg.tabPn.colorTab.infotxt.preferredSize = [500,35];
                    dlg.tabPn.colorTab.fadeGp = dlg.tabPn.colorTab.add('group');
                        dlg.tabPn.colorTab.fadeGp.orientation = 'row';
                        dlg.tabPn.colorTab.fadeGp.alignChildren = ['left','middle'];
                        
                        dvar.cyanStep = dlg.tabPn.colorTab.fadeGp.add('edittext',undefined,0);dvar.cyanStep.name = 'cyanStep';
                            dvar.cyanStep.size = boxSize;
                        dvar.magentaStep = dlg.tabPn.colorTab.fadeGp.add('edittext',undefined,0);dvar.magentaStep.name = 'magentaStep';
                            dvar.magentaStep.size = boxSize;
                        dvar.yellowStep = dlg.tabPn.colorTab.fadeGp.add('edittext',undefined,0);dvar.yellowStep.name = 'yellowStep';
                            dvar.yellowStep.size = boxSize;
                        dvar.densStep = dlg.tabPn.colorTab.fadeGp.add('edittext',undefined,0);dvar.densStep.name = 'densStep';
                            dvar.densStep.size = boxSize;                        
                            dvar.cyanStep.onChange = function(){textToNum(-1,1,this,'float',false)};
                            dvar.magentaStep.onChange = function(){textToNum(-1,1,this,'float',false)};
                            dvar.yellowStep.onChange = function(){textToNum(-1,1,this,'float',false)};
                            dvar.densStep.onChange = function(){textToNum(-1,1,this,'float',false)};
                            
                        dlg.tabPn.colorTab.fadeGp.colorStepStxt = dlg.tabPn.colorTab.fadeGp.add('statictext',undefined,'Color Fade Step increments (-1~1) C, Y, M, K')
                        
                    //Color Fade Starting point===================================

                    dlg.tabPn.colorTab.fadeStartGp = dlg.tabPn.colorTab.add('group');
                        dlg.tabPn.colorTab.fadeStartGp.orientation = 'row';
                        dlg.tabPn.colorTab.fadeStartGp.alignChildren = ['left','middle'];
                        
                        
                        dvar.cyanStart = dlg.tabPn.colorTab.fadeStartGp.add('edittext',undefined,0);dvar.cyanStart
                            dvar.cyanStart.size = boxSize;
                        dvar.magentaStart = dlg.tabPn.colorTab.fadeStartGp.add('edittext',undefined,0);dvar.magentaStart.name = 'magentaStart';
                            dvar.magentaStart.size = boxSize;
                        dvar.yellowStart = dlg.tabPn.colorTab.fadeStartGp.add('edittext',undefined,0);dvar.yellowStart.name = 'yellowStart';
                            dvar.yellowStart.size = boxSize;
                        dvar.densityStart = dlg.tabPn.colorTab.fadeStartGp.add('edittext',undefined,0);dvar.densityStart.name = 'densityStart';
                            dvar.densityStart.size = boxSize;                        
                            dvar.cyanStart.onChange = function(){textToNum(0,1,this,'float',false)};
                            dvar.magentaStart.onChange = function(){textToNum(0,1,this,'float',false)};
                            dvar.yellowStart.onChange = function(){textToNum(0,1,this,'float',false)};
                            dvar.densityStart.onChange = function(){textToNum(0,1,this,'float',false)}; 
                            
                        dlg.tabPn.colorTab.fadeStartGp.colorStepStxt = dlg.tabPn.colorTab.fadeStartGp.add('statictext',undefined,'Color Fade Starting Point (0~1) C, Y, M, K')
                            
                    dlg.tabPn.colorTab.fadeAltGp = dlg.tabPn.colorTab.add('group');
                        dlg.tabPn.colorTab.fadeAltGp.orientation = 'row';
                        dlg.tabPn.colorTab.fadeAltGp.alignChildren = ['left','middle'];
                        
                        dlg.tabPn.colorTab.fadeAltGp.sTxt = dlg.tabPn.colorTab.fadeAltGp.add('statictext',undefined,'Fades back and forth');
                        dvar.cyanAlt = dlg.tabPn.colorTab.fadeAltGp.add('checkbox',undefined,'Cyan');dvar.cyanAlt.name = 'cyanAlt';
                        dvar.magentaAlt = dlg.tabPn.colorTab.fadeAltGp.add('checkbox',undefined,'Magenta');dvar.magentaAlt.name = 'magentaAlt';
                        dvar.yellowAlt = dlg.tabPn.colorTab.fadeAltGp.add('checkbox',undefined,'Yellow');dvar.yellowAlt.name = 'yellowAlt';
                        dvar.densAlt = dlg.tabPn.colorTab.fadeAltGp.add('checkbox',undefined,'Density');dvar.densAlt.name = 'densAlt';

                    dlg.tabPn.colorTab.fileLine2 = dlg.tabPn.colorTab.add('panel',undefined,undefined, {borderStyle: 'sunken'});
                        dlg.tabPn.colorTab.fileLine2.alignment = ['fill','top'];
                        
                    dlg.tabPn.colorTab.blendGp = dlg.tabPn.colorTab.add('group');
                        dlg.tabPn.colorTab.blendGpalignment = ['fill','top'];
                        
                        dvar.blendDbx = dlg.tabPn.colorTab.blendGp.add('dropdownlist',undefined,blendList);dvar.blendDbx.name = 'blendDbx';
                            dvar.blendDbx.title = '   Blend Mode with layer';
                            dvar.blendDbx.titleLayout ={alignment: ['right','center']};           
                            dvar.blendDbx.selection = 0;
                            
                            if(app.activeDocument.activeLayer.isBackgroundLayer){
                                dvar.blendDbx.items[2].enabled = false;
                                dvar.blendDbx.items[3].enabled = false;
                                }  
                            
                        dvar.patternBlendDbx = dlg.tabPn.colorTab.blendGp.add('dropdownlist',undefined,patternBlendList);dvar.patternBlendDbx.name = 'patternBlendDbx';
                            dvar.patternBlendDbx.title = '   Blend Mode with other patterns';
                            dvar.patternBlendDbx.titleLayout ={alignment: ['right','center']};           
                            dvar.patternBlendDbx.selection = 0;                            
            ////////////////////////Size and Spacing////////////////////////////////////////////////
            dlg.tabPn.sizeTab = dlg.tabPn.add('tab',undefined,'Size and Spacing');
                dlg.tabPn.sizeTab.alignChildren = ['left','top'];  
                
                dlg.tabPn.sizeTab.spaceRbGp = dlg.tabPn.sizeTab.add('group');
               
                    dvar.spPx = dlg.tabPn.sizeTab.spaceRbGp.add('radiobutton',undefined,'In pixels');dvar.spPx.name = 'spPx';
                        dvar.spPx.value = true;
                    dvar.spPrecent = dlg.tabPn.sizeTab.spaceRbGp.add('radiobutton',undefined,'In percent of pattern');dvar.spPrecent.name = 'spPrecent';
                    
                dlg.tabPn.sizeTab.spaceGp = dlg.tabPn.sizeTab.add('group');
                    dlg.tabPn.sizeTab.spaceGp.alignment = ['fill','top'];
                    
                    dvar.spaceX = dlg.tabPn.sizeTab.spaceGp.add('edittext',undefined,0);dvar.spaceX.name = 'spaceX';
                        dvar.spaceX.size = boxSize;
                        dvar.spaceX.onChange = function(){textToNum(-90,100,this,'float',false)};
                    
                    dlg.tabPn.sizeTab.spaceGp.spaceXStxt = dlg.tabPn.sizeTab.spaceGp.add('statictext',undefined,'X Spacing (-90~100)');
                    
                    dvar.spaceY = dlg.tabPn.sizeTab.spaceGp.add('edittext',undefined,0);dvar.spaceY.name = 'spaceY';
                        dvar.spaceY.size = boxSize;
                        dvar.spaceY.alignment = ['center','middle']
                        dvar.spaceY.onChange = function(){textToNum(-90,100,this,'float',false)}; 
                        
                    dlg.tabPn.sizeTab.spaceGp.spaceYStxt = dlg.tabPn.sizeTab.spaceGp.add('statictext',undefined,'Y Spacing (-90~100)');
                    
                    dlg.tabPn.sizeTab.fileLine = dlg.tabPn.sizeTab.add('panel',undefined,undefined, {borderStyle: 'sunken'});
                        dlg.tabPn.sizeTab.fileLine.alignment = ['fill','top'];    
                        
                dlg.tabPn.sizeTab.scaleGp = dlg.tabPn.sizeTab.add('group');                        
                    dlg.tabPn.sizeTab.scaleGp.alignment = ['fill','top'];
                    dlg.tabPn.sizeTab.scaleGp.alignChildren = lftM;

                    dvar.patternScale = dlg.tabPn.sizeTab.scaleGp.add('edittext',undefined,1);dvar.patternScale.name = 'patternScale';
                        dvar.patternScale.size = boxSize;
                        dvar.patternScale.onChange = function(){textToNum(.01,3,this,'float',false)};
                        
                    dlg.tabPn.sizeTab.scaleGp.scaleStxt = dlg.tabPn.sizeTab.scaleGp.add('statictext',undefined,'Scale (.01~3 Use numbers between .001 and 1 for reductions');
                    
            ////////////////////////Reference File////////////////////////////////////////////////
            dlg.tabPn.refTab = dlg.tabPn.add('tab',undefined,'Reference File');
                dlg.tabPn.refTab.alignChildren = ['left','top'];             
                                   
                    dlg.tabPn.refTab.refOptGp = dlg.tabPn.refTab.add('group');
                        dlg.tabPn.refTab.refOptGp.orientation = 'row';
                        dlg.tabPn.refTab.refOptGp.alignChildren = lftM;
                        dlg.tabPn.refTab.refOptGp.alignment = ['fill','top'];    
                       
                        dvar.useRefFile = dlg.tabPn.refTab.refOptGp.add('checkbox',undefined,'Use Ref File');dvar.useRefFile.name = 'useRefFile';
                            dvar.useRefFile.onClick = function(){enableUI()};
                        dvar.assignColor = dlg.tabPn.refTab.refOptGp.add('checkbox',undefined,'Assign Color to Patterns');dvar.assignColor.name = 'assignColor';
                            dvar.assignColor.onClick = function(){enableUI()};
                        dvar.refSize = dlg.tabPn.refTab.refOptGp.add('checkbox',undefined,'Scale by Density');dvar.refSize.name = 'refSize';
                            dvar.refSize.onClick = function(){enableUI()};
                        dvar.refRotate = dlg.tabPn.refTab.refOptGp.add('checkbox',undefined,'Rotate by Density');dvar.refRotate.name = 'refRotate';
                            dvar.refRotate.onClick = function(){enableUI()};
                            
                    dlg.tabPn.refTab.fillRangeGp = dlg.tabPn.refTab.add('group');
                        dlg.tabPn.refTab.fillRangeGp.orientation = 'row';
                        dlg.tabPn.refTab.fillRangeGp.alignChildren = lftM;
                        dlg.tabPn.refTab.fillRangeGp.alignment = ['fill','top'];
                        
                        dvar.fillAll=dlg.tabPn.refTab.fillRangeGp.add('radiobutton',undefined,'Fill All');dvar.fillAll.name = 'fillAll';
                            dvar.fillAll.onClick = function(){enableUI()};
                        dvar.fillBlack=dlg.tabPn.refTab.fillRangeGp.add('radiobutton',undefined,'Fill Black Area');dvar.fillBlack.name = 'fillBlack';
                            dvar.fillBlack.onClick = function(){enableUI()};
                        dvar.fillWhite=dlg.tabPn.refTab.fillRangeGp.add('radiobutton',undefined,'Fill White Area');dvar.fillWhite.name = 'fillWhite';
                            dvar.fillWhite.onClick = function(){enableUI()};
                        dvar.fillRange=dlg.tabPn.refTab.fillRangeGp.add('radiobutton',undefined,'Fill Tonal Range Area');dvar.fillRange.name = 'fillRange';
                            dvar.fillRange.onClick = function(){enableUI()};
                        dvar.fillAll.value = true;
                        
                        dvar.fillMinStxt = dlg.tabPn.refTab.fillRangeGp.add('statictext',undefined,'Fill Range Min:');
                        dvar.fillMin = dlg.tabPn.refTab.fillRangeGp.add('edittext',undefined,0);dvar.fillMin.name = 'fillMin';
                        dvar.fillMin.size  = [40,15];
                        dvar.fillMin.onChange = function(){textToNum(0,100,this,'float',false)};
                        
                        dvar.fillMaxStxt = dlg.tabPn.refTab.fillRangeGp.add('statictext',undefined,'Fill Range Max (CYMK):');
                        dvar.fillMax = dlg.tabPn.refTab.fillRangeGp.add('edittext',undefined,100);dvar.fillMax.name = 'fillMax';
                        dvar.fillMax.size  = [40,15];                        
                        dvar.fillMax.onChange = function(){textToNum(0,100,this,'float',false)};

                       
                    dlg.tabPn.refTab.colorLevelGp = dlg.tabPn.refTab.add('group');
                        dlg.tabPn.refTab.colorLevelGp.orientation = 'row';
                        dlg.tabPn.refTab.colorLevelGp.alignChildren = lftM;
                        dlg.tabPn.refTab.colorLevelGp.alignment = ['fill','top'];
                        
                        
                        
                        dvar.refColorLevel = dlg.tabPn.refTab.colorLevelGp.add('edittext',undefined,90);dvar.refColorLevel.name = 'refColorLevel';
                            dvar.refColorLevel.onChange = function(){textToNum(0,100,this,'float',false)};
                            dvar.refColorLevel.size = boxSize;
                            
                        dlg.tabPn.refTab.colorLevelGp.colorStxt = dlg.tabPn.refTab.colorLevelGp.add('statictext',undefined,'Percent of reference color applied to pattern');
   
                        dvar.refBlackLevel = dlg.tabPn.refTab.colorLevelGp.add('edittext',undefined,90);dvar.refBlackLevel.name = 'refBlackLevel';
                            dvar.refBlackLevel.onChange = function(){textToNum(0,100,this,'float',false)};
                            dvar.refBlackLevel.size = boxSize;
                            dvar.refBlackLevel.alignment = rtM;
                            
                        dlg.tabPn.refTab.colorLevelGp.blackStxt = dlg.tabPn.refTab.colorLevelGp.add('statictext',undefined,'Percent of reference black/density applied to pattern');
                        
                        dvar.assignColor.value ? dlg.tabPn.refTab.colorLevelGp.enabled = true : dlg.tabPn.refTab.colorLevelGp.enabled = false;
                        
                    dlg.tabPn.refTab.sizeGp = dlg.tabPn.refTab.add('group');
                        dlg.tabPn.refTab.sizeGp.orientation = 'row';
                        dlg.tabPn.refTab.sizeGp.alignChildren = lftM;
                        dlg.tabPn.refTab.sizeGp.alignment = ['fill','top'];                                                   
                            
                        dvar.refSizeMin = dlg.tabPn.refTab.sizeGp.add('edittext',undefined,.1);dvar.refSizeMin.name = 'refSizeMin';
                            dvar.refSizeMin.onChange = function(){textToNum(.1,1,this,'float',false)};
                            dvar.refSizeMin.size = boxSize;
                            
                        dlg.tabPn.refTab.sizeGp.minStxt = dlg.tabPn.refTab.sizeGp.add('statictext',undefined,'Min Size (.1~1)');
                            
                        dvar.refSizeMax = dlg.tabPn.refTab.sizeGp.add('edittext',undefined,1);dvar.refSizeMax.name = 'refSizeMax';
                            dvar.refSizeMax.onChange = function(){textToNum(.5,3,this,'float',false)};
                            dvar.refSizeMax.size = boxSize;
                            
                        dlg.tabPn.refTab.sizeGp.maxStxt = dlg.tabPn.refTab.sizeGp.add('statictext',undefined,'Max Size (.5~3)');
                        
//////////////////////////////
                    dlg.tabPn.refTab.rotateGp = dlg.tabPn.refTab.add('group');
                        dlg.tabPn.refTab.rotateGp.orientation = 'row';
                        dlg.tabPn.refTab.rotateGp.alignChildren = lftM;
                        dlg.tabPn.refTab.rotateGp.alignment = ['fill','top']; 
                        
                        dvar.limitRotation = dlg.tabPn.refTab.rotateGp.add('checkbox',undefined,'Limit rotation angles to:');dvar.limitRotation.name = 'limitRotation';
                            dvar.limitRotation.onClick = function(){enableUI()};

                        dvar.limitRotationEtxt = dlg.tabPn.refTab.rotateGp.add('edittext',undefined,'60');dvar.limitRotationEtxt.name = 'limitRotationEtxt';
                            dvar.limitRotationEtxt.onChange = function(){textToNum(5,180,this,'int',false)};                        
                            dvar.limitRotationEtxt.size = boxSize;
                            
                        dvar.r360 = dlg.tabPn.refTab.rotateGp.add('radiobutton',undefined,'Allow full 360 deg. rotation.');dvar.r360.name = 'r360';
                            dvar.r360.helpTip = 'Use if pattern looks different rotated past 180 deg.';
                            dvar.r360.value = true;
                        dvar.r180 = dlg.tabPn.refTab.rotateGp.add('radiobutton',undefined,'limit rotation to 180 deg.');dvar.r180.name = 'r180';
                            dvar.r180.helpTip = 'Use if pattern looks the same rotated 180 deg.';

                        
                    dlg.tabPn.refTab.fileLine = dlg.tabPn.refTab.add('panel',undefined,undefined, {borderStyle: 'sunken'});
                        dlg.tabPn.refTab.fileLine.alignment = ['fill','top'];     
                        
////////////////////////////////////////Bottom part of Reference File - Creating and Loading the File
                
                dlg.tabPn.refTab.infoStxt = dlg.tabPn.refTab.add('statictext',undefined,'Create a Reference file:\nThis may take several minutes depending upon the size of the file and the size of the steps.\nThe smaller the steps, the longer the time.',{multiline:true})
                    dlg.tabPn.refTab.infoStxt.size = [600,50];
                    
                dlg.tabPn.refTab.sampleSizeGp = dlg.tabPn.refTab.add('group');
                    dlg.tabPn.refTab.sampleSizeGp.alignment = ['fill','top'];
                        dlg.tabPn.refTab.sampleSizeGp.alignChildren = lftM;
                        
                        dvar.xSampleSize = dlg.tabPn.refTab.sampleSizeGp.add('edittext',undefined,50);dvar.xSampleSize.name = 'xSampleSize';
                            dvar.xSampleSize.size = boxSize;
                            dvar.xSampleSize.onChange = function(){textToNum(10,1000,this,'int',false)};
                        dlg.tabPn.refTab.sampleSizeGp.xStxt = dlg.tabPn.refTab.sampleSizeGp.add('statictext',undefined,'X step size of sample (10~1000)')
                       
                        dvar.ySampleSize = dlg.tabPn.refTab.sampleSizeGp.add('edittext',undefined,50);dvar.ySampleSize.name = 'ySampleSize';
                            dvar.ySampleSize.size = boxSize;
                            dvar.ySampleSize.alignment = ['center','middle'];
                            dvar.ySampleSize.onChange = function(){textToNum(10,1000,this,'int',false)};
                        dlg.tabPn.refTab.sampleSizeGp.yStxt = dlg.tabPn.refTab.sampleSizeGp.add('statictext',undefined,'Y step size of sample (10~1000)');

                        dlg.tabPn.refTab.makeBtn = dlg.tabPn.refTab.add('button',undefined,'Make and Save Reference File');
                            dlg.tabPn.refTab.makeBtn.onClick = function(){
                                dvar.refName.text = 'creating'
                                dvar.refInfo.text = ' '
                                refFile = refFile.saveDlg ('Save Reference File','xml: *.xml');
                                 createRefFile(refFile,parseInt(dvar.xSampleSize.text),parseInt(dvar.ySampleSize.text))
                                };//end onclick for makeBtn

                        dlg.tabPn.refTab.loadBtn = dlg.tabPn.refTab.add('button',undefined,'Open Reference File');
                            dlg.tabPn.refTab.loadBtn.onClick = function(){
                                refFile = refFile.openDlg ('Open Reference File','xml: *.xml');
                                 refXML = new XML(readXMLFile(refFile))
                                 refSame()
                                };//end onclick for loadBtn
                            
                        dvar.refName = dlg.tabPn.refTab.add('statictext',undefined,'No reference file selected');dvar.refName.name = 'refName'
                            dvar.refName.characters = 120;
                            dvar.refName.alignment = ['left','top'];
                        dvar.refInfo = dlg.tabPn.refTab.add('statictext',undefined,' ');
                            dvar.refInfo.alignment = ['left','top'];
                            dvar.refInfo.characters = 100;

///////////////////////////////End tabbed groups//////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////Presets///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                           
    dlg.presetPn = dlg.add('panel',undefined,'Presets')
        dlg.presetPn.orientation = 'row';
        dlg.presetPn.alignChildren = ['left','middle'];
        
        dvar.presetsDbx = dlg.presetPn.add('dropdownlist',undefined,presetList);
            dvar.presetsDbx.size = [400,22];
            dvar.presetsDbx.onChange = function(){
                  if(prefXML.children().length()>0){//loads presets into UI   
                        setUIvar(prefXML,parseInt(dvar.presetsDbx.selection),dlg);
                  };                
            };

            
        dlg.presetPn.saveBtn = dlg.presetPn.add('button',undefined,'Save Preset');
        dlg.presetPn.deleteBtn = dlg.presetPn.add('button',undefined,'Delete Current Preset');
        
        dlg.presetPn.saveBtn.onClick = function(){
            saveName = prompt ('Enter a name for the preset', '', 'Preset Save')
            if(saveName){storePrefs('a')}
            dvar.presetsDbx.selection = dvar.presetsDbx.items.length -1
            };
        
        dlg.presetPn.deleteBtn.onClick = function(){
            if(!parseInt(dvar.presetsDbx.selection)){alert('You must select a preset to delete first')}
            else if(parseInt(dvar.presetsDbx.selection) == 0){alert("You can't delete the current default preset")}
            else{
                var delPre = confirm ('Do you want to delete the preset "' + dvar.presetsDbx.selection.text +'"?', 'Yes', 'Delete Preset')
                if(delPre){
                    delete prefXML.presets.preset[parseInt(dvar.presetsDbx.selection)];
                    setPresetList();
                    writeXMLFile(uiPref,prefXML);
                    dvar.presetsDbx.selection = 0
                }//end if
            };//end else
        };//end function
    
////////////////////////Okay/Cancel buttons////////////////////////////////////////////////////////////////////////////
    dlg.btnGp = dlg.add('group');
        dlg.btnGp.alignment = ['fill','top'];
        dlg.btnGp.alignChildren = ['center','middle'];
        
        dlg.btnGp.ok = dlg.btnGp.add('button',undefined,'Okay');
        dlg.btnGp.cancel = dlg.btnGp.add('button',undefined,'Cancel');
        dlg.btnGp.defaultBtn = dlg.btnGp.add('button',undefined,'Default');
        
        
        dlg.btnGp.ok.onClick = function(){
            
            if(runProg){
                dlg.close()
                dvar.r360.value ? rLimit = 1.2  : rLimit = .6
                storePrefs('r')
                seed2Temp = dvar.seed.text
                getPasses () 
                }//end if
            runProg = true;
            };//end function
    
        dlg.btnGp.cancel.onClick = function(){dlg.close()} ;   
        
        dlg.btnGp.defaultBtn.onClick = function(){
            reset = true;
            dlg.close()
            ui()
            reset = false;
            };//end default button
        
      if(prefXML.children().length()>0 && !reset){//loads presets into UI
            setPresetList()    
            setUIvar(prefXML,0,dlg)
            dvar.presetsDbx.selection = 0
            enableUI ()
            
      };        

    dlg.show();
    };//end function ui

///////////////////////////////Update UI var after preset load//////////////////////////////////////////////////////////////////////////////////////////////


//Checks to see if the reference file matches the size of the selection
function refSame(){
     dvar.xSampleSize.text = refXML.info.@sx;
     dvar.ySampleSize.text = refXML.info.@sy;
                               
     try{
         if(parseInt(docRef.selection.bounds[2] - docRef.selection.bounds[0]) != parseInt(refXML.info.@x) && parseInt(docRef.selection.bounds[3] - docRef.selection.bounds[1]) != parseInt(refXML.info.@y)){
            dvar.refInfo.text = 'The selection size does not match the reference file size'
            dvar.useRefFile.value = dvar.assignColor.value = dvar.assignColor.enabled = dvar.refSize.value = dvar.refSize.enabled = dvar.refRotate.value = dvar.refRotate.enabled = false;        
            }
        else{dvar.refInfo.text = refXML.info}
         }
     catch(e){
         if(parseInt(docRef.width) != parseInt(refXML.info.@x) && parseInt(docRef.height) != parseInt(refXML.info.@y)){
            dvar.refInfo.text = 'The document size does not match the reference file size'
            dvar.useRefFile.value = dvar.assignColor.value = dvar.assignColor.enabled = dvar.refSize.value = dvar.refSize.enabled = dvar.refRotate.value = dvar.refRotate.enabled = false;
            }
        else{dvar.refInfo.text = refXML.info}
         }
     dvar.refName.text = refFile.fsName
    }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////Function to get the max and min numbers needed for the number of passes selected.
function getPasses(){
    divideNum = 1/parseInt(dvar.pass.text)
    
    for(s=0;s<=parseInt(dvar.pass.text);s++){//breaks up number of passes to values for random number
        rangeNumArray[s] = s*divideNum
        } ;

    for(t=0;t<parseInt(dvar.pass.text);t++){
        minValTemp = rangeNumArray[t]
        maxValTemp = rangeNumArray[t+1]
        doFill ()
        }
    };//end function getPasses

//////////////////////////////For putting the code for the temp script file into an array to write the temp file.
function doFill(){
    try{tempScript.close()}
    catch(e){}
    switch(parseInt(dvar.scriptDbx.selection)){
        case 0:
            scriptArray = brickScriptToArray ()
            break;
        case 1: 
            scriptArray = weaveScriptToArray ()
            break;
        case 2:
            scriptArray = spiralScriptToArray ()
            break;
        case 3:
            scriptArray = randomScriptToArray ()
            break;
        case 4:
            scriptArray = randomBorderScriptToArray()
            break;            
        case 5: 
            scriptArray = symmetryScriptToArray ()
            break;

    };//end switch
    
    writeXMLFile(tempScript,false)
    if(tempScript.exists){dFill()}
    else{alert('There is a problem writing a temp file\rMake sure you have permission\rto write to the deco script folder')}
}

//////////////////////////////////////////Scriptlistener code for running fill////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//ScriptListener generated code for capturing the action of running the deco script.

function dFill(){
        //Switch for blend
        switch(parseInt(dvar.blendDbx.selection)){
            case 0:
                blendM = "Nrml"
                break;
            case 1:
                blendM = "Dslv"
                break;
            case 2:
                blendM = "Bhnd"
                break;
            case 3:
                blendM = "Clar"
                break;
            case 5:
                blendM = "Drkn"
                break;
            case 6:
                blendM = "Mltp"
                break;
            case 7:
                blendM = "CBrn"
                break;
            case 8:
                blendM = "linearBurn"
                break;
            case 9:
                blendM = "darkerColor"
                break;
            case 11:
                blendM = "Lghn"
                break;
            case 12:
                blendM = "Scrn"
                break;
            case 13:
                blendM = "CDdg"
                break;
            case 14:
                blendM = "linearDodge"
                break;
            case 15:
                blendM = "lighterColor"
                break;
            case 17:
                blendM = "Ovrl"
                break;
            case 18:
                blendM = "SftL"
                break;
            case 19:
                blendM = "HrdL"
                break;
            case 20:
                blendM = "vividLight"
                break;
            case 21:
                blendM = "linearLight"
                break;
            case 22:
                blendM = "pinLight"
                break;
            case 23:
                blendM = "hardMix"
                break;
            case 25:
                blendM = "Dfrn"
                break;
            case 26:
                blendM = "Xclu"
                break;
            case 27:
                blendM = "blendSubtraction"
                break;
            case 28:
                blendM = "blendDivide"
                break;
            case 30:
                blendM = "H   "
                break;
            case 31:
                blendM = "Strt"
                break;
            case 32:
                blendM = "Clr "
                break;
            case 33:
                blendM = "Lmns"
                break;
                        
            };//end switch

    if(dvar.addLayer.value){app.activeDocument.artLayers.add()}
    
var idFl = charIDToTypeID( "Fl  " );
    var desc8 = new ActionDescriptor();
    var idUsng = charIDToTypeID( "Usng" );
    var idFlCn = charIDToTypeID( "FlCn" );
    var idPtrn = charIDToTypeID( "Ptrn" );
    desc8.putEnumerated( idUsng, idFlCn, idPtrn );
    var idPtrn = charIDToTypeID( "Ptrn" );
        var desc9 = new ActionDescriptor();
        var idNm = charIDToTypeID( "Nm  " );
        desc9.putString( idNm, """red""" );
        var idIdnt = charIDToTypeID( "Idnt" );
        desc9.putString( idIdnt, """dc8f42fd-5c3a-11e1-a8b2-da9da9bff8b9""" );
    var idPtrn = charIDToTypeID( "Ptrn" );
    desc8.putObject( idPtrn, idPtrn, desc9 );
    var iddecoScriptFile = stringIDToTypeID( "decoScriptFile" );
    desc8.putPath( iddecoScriptFile, new File( tempScript ) );
    var idOpct = charIDToTypeID( "Opct" );
    var idPrc = charIDToTypeID( "#Prc" );
    desc8.putUnitDouble( idOpct, idPrc, 100.000000 );
    var idMd = charIDToTypeID( "Md  " );
    var idBlnM = charIDToTypeID( "BlnM" );
    if(blendM.length > 4){var idNrml = stringIDToTypeID( blendM );}
    else{var idNrml = charIDToTypeID( blendM );}
    desc8.putEnumerated( idMd, idBlnM, idNrml );
executeAction( idFl, desc8, DialogModes.ALL );

try{
	app.displayDialogs = DialogModes.NO; 
    setActionToAcc()
	}
catch(e){};

    }

//////////////////////////////////////READ/WRITE XML functions//////////////////////////////////////////////////////////////////////////////////

 function readXMLFile(file) {
	if (!file.exists) {
		alert( "Cannot find file: " + deodeURI(file.absoluteURI));
		}
	else{
		file.encoding = "UTF8";
		file.lineFeed = "unix";
		file.open("r", "TEXT", "????");
		var str = file.read();
		file.close();

		return new XML(str);
		};
};

function writeXMLFile(file, xml) {
    file.encoding = "UTF8";
    file.open("w", "TEXT", "????");
    //unicode signature, this is UTF16 but will convert to UTF8 "EF BB BF"
    file.write("\uFEFF");
    file.lineFeed = "unix";
	if (!(xml instanceof XML)) {
        for(var g=0;g<scriptArray.length;g++){
            try{
                file.writeln (scriptArray[g].toString())
                }
            catch(e){$.writeln (e)}
         };//end for loop			
		}
	else{file.write(xml.toXMLString())};
    file.close();
	};

//////////////////////////////////////Create Ref File///////////////////////////////////////////////////////////////////////
function createRefFile(file,xStepSize,yStepSize){
refXML = new XML('<root><info/><lines/></root>')
var n = 0
var pixelLoc = new Array
var bwA = new Array()
var xSize,ySize,xStart,yStart,fromArea
try{
    xSize = parseInt(docRef.selection.bounds[2] - docRef.selection.bounds[0]);
    ySize = parseInt(docRef.selection.bounds[3] - docRef.selection.bounds[1]);
    xStart = parseInt(docRef.selection.bounds[0]);
    yStart = parseInt(docRef.selection.bounds[1]);
    fromArea = 'Selection size: ' 
    }
catch(e){
    xStart = yStart = 0
    xSize = parseInt(docRef.width);
    ySize = parseInt(docRef.height);
    fromArea = 'Document Size: '
    }
var xNum =  Math.floor (xSize/xStepSize)
var yNum =  Math.floor (ySize/yStepSize)
var cs, hold
var y = yStart + yStepSize/2
var x = xStart + xStepSize/2
refXML.info= XML('<info x="' + xSize + '" y="'+ ySize + '" sx="' + dvar.xSampleSize.text + '" sy="' + dvar.ySampleSize.text + '">' + fromArea + xSize + ' X ' + ySize + '</info>');


       for(var yn=0;yn<yNum;yn++){
            x = xStart + xStepSize/2
            
            if(x>docRef.width){x = parseInt(docRef.width)}
            refXML.lines.appendChild(XML('<item y="' + yn + '">new</item>'));
             
            for(var xn=0;xn<xNum;xn++){
             //get the pixel locations
            docRef.colorSamplers.removeAll();
            pixelLoc = new Array()
            pixelLoc = [UnitValue(x + " pixels") , UnitValue(y + " pixels")]; 
        
            try{          
                docRef.colorSamplers.add(pixelLoc)
                cs = docRef.colorSamplers[0].color
                refXML.lines.appendChild(XML('<item y="' + yn + '" x="' + xn + '">' + cs.cmyk.cyan + '~' + cs.cmyk.magenta + '~' + cs.cmyk.yellow + '~' + cs.cmyk.black + '</item>'));
                }
            catch(e){refXML.lines.appendChild(XML('<item y="' + yn + '" x="' + xn + '">null</item>'));}
            x+=xStepSize
            docRef.colorSamplers.removeAll();
            }//end for loop for x num
            y+=yStepSize
            if(y>docRef.height){y= parseInt(docRef.height)}
         };//end for loop for y num
     
        dvar.refInfo.text = refXML.info;
        dvar.refName.text = refFile.fsName
    writeXMLFile(refFile, refXML);
    };//end createRefFile


///////////////////////////////////////////////////////////////////////////////////
//check the UI variables to make sure they are numbers and if number whether they are intergers or floating decimal numbers.
//Give alert of value is either not a number or out of the desired range.
//////////////////////////////////////////////////////////////////////////////////
function textToNum(sMin,sMax,e,par,zero){
	var sHold = sMin;
	if(zero){alert('This number can not be zero')}
	else if(par == 'int'){
		if(isNaN(parseInt(e.text))){
              runProg = false;
			alert('"' + e.text + '" is not a number\nEnter a value between ' + sMin + '~' + sMax );
			e.text = sMin};
              
		else{sHold = parseInt(e.text)
			if(sHold < sMin){
				rangeAlert();
				sHold = sMin;				
				};
			if(sHold > sMax){
				rangeAlert();
				sHold = sMax;
				};
			e.text = sHold;
			};	//end else
		};//end if par
	else{
		if(isNaN(parseFloat(e.text))){
			alert('"' + e.text + '" is not a number\nEnter a value between ' + sMin + '~' + sMax );
			e.text = sMin};
		else{sHold = parseFloat(e.text)
			if(sHold < sMin){
				rangeAlert();
				sHold = sMin;
				};
			if(sHold > sMax){
				rangeAlert();
				sHold = sMax;
				};
			e.text = sHold;
			};	//end else
		};//end else par
	function rangeAlert(){
        runProg = false;
        alert('Number range must be between ' + sMin + '~' + sMax)
        }; 
    runProg = true
};//end function textToNum

////////////////////////////////Presets//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function storePrefs(meth){
    var tempXML
    
    if(meth == 'r'){
        tempXML = new XML(startNodes);
        setXML(tempXML,0,dlg);
      
        if(prefXML.children().length()==0){
            prefXML = new XML(tempXML);
            }
        else{
            prefXML.presets.preset[0] = XML(tempXML.presets.preset[0])        
            };
        }//end if for method
    else{
        tempXML = new XML('<root><presets><preset presetName ="' + saveName + '"/></presets></root>');
        setXML(tempXML,0,dlg);
        prefXML.presets.appendChild (XML(tempXML.presets.preset[0]))
        setPresetList()
        };//end else for appending xml
      
      writeXMLFile(uiPref,prefXML);
      
      };//end function storePrefs
  
 
/////////////////////////////////////////////////////////////////////////////////////////////////////
//function loops through the ui object and if the control items have been assigned a name it stores the name and the value to an XML file.
 function setXML(x,n,d){//x = xml file, n = starting node, d = dialog.
    for(var i = 0;i<d.children.length;i++){
       if(d.children[i].type == 'panel' || d.children[i].type == 'group' || d.children[i].type == 'tabbedpanel' || d.children[i].type == 'tab'){setXML(x,n,d.children[i])}//loops though UI and restarts function if it comes to a container that might have more children
        else{
            if(d.children[i].name){//check to make sure the control has a name assigned so that it only records those with name.
                switch(d.children[i].type){
                    case 'radiobutton':
                        x.presets.child(n).appendChild(XML('<' + d.children[i].name +' type="' + d.children[i].type + '">' + d.children[i].value + '</' + d.children[i].name + '>'));                        
                        break;
                    case 'checkbox':
                        x.presets.child(n).appendChild(XML('<' + d.children[i].name +' type="' + d.children[i].type + '">' + d.children[i].value + '</' + d.children[i].name + '>'));                        
                        break;
                    case 'slider':
                        x.presets.child(n).appendChild(XML('<' + d.children[i].name +' type="' + d.children[i].type + '">' + d.children[i].value + '</' + d.children[i].name + '>'));                        
                        break;
                    case 'edittext':    
                        x.presets.child(n).appendChild(XML('<' + d.children[i].name +' type="' + d.children[i].type + '"><![CDATA[' + d.children[i].text + ']]\></' + d.children[i].name + '>'));                        
                        break;
                    case 'statictext':
                        if(dvar.useRefFile.value){
                            x.presets.child(n).appendChild(XML('<' + d.children[i].name +' type="' + d.children[i].type + '"><![CDATA[' + refFile.fsName + ']]\></' + d.children[i].name + '>'));                        
                            }//end if
                        break;                        
                    case 'dropdownlist':
                        if(d.children[i].selection){varHold = d.children[i].selection.text}
                        else{varHold = 'null'};
                        x.presets.child(n).appendChild(XML('<' + d.children[i].name +' selecIndex="' + d.children[i].selection + '" type="' + d.children[i].type + '"><![CDATA[' + varHold + ']]\></' + d.children[i].name + '>'));                        
                        break;
                  };//end switch
                }//end if for child having name
            };//end else
        };//end for loop
 }//end function setXML

////////////////////////////////////////////////////////////////////////////////////////////////
//function loops through the ui object and if a control item has been assigned a name uses that name to look up the preset value in the XML.
function setUIvar(x,n,d){//x= xml file; n = node number (0 is default node), d = UI dialog

    var currentXMLVal;//used to store values from XML file.  When this value is assigned, it checks to see if value from XML exist
    var noMatch = false
    
    for(var i = 0;i<d.children.length;i++){
        noMatch = false;
        
        if(d.children[i].type == 'panel' || d.children[i].type == 'group' || d.children[i].type == 'tab' || d.children[i].type == 'tabbedpanel'){setUIvar(x,n,d.children[i])};//reruns function if child is container and not control item.	
        else{
            if(d.children[i].name){//Checks to see if child has a name assigned so only will reset those control items that have a name will be stored.
                try{
                    //Assigns all variables from presets node.  The "n" tells which preset to select. "0" is always the default preset (last saved).
                        currentXMLVal = x.presets.preset[n].child(d.children[i].name);                        
                    if(currentXMLVal == 'null'){currentXMLVal = null};
                    }//end try
                //catch assigns 'no_good' to current XMLVal so that if there is no value in the XML file, it will not try to assign a bad value to the UI controls.
                catch(e){currentXMLVal = 'no_good'};//end catch
                //switch makes sure proper type of value is reassigned back to UI controls.
                if(x.presets.preset[n].child(d.children[i].name).length() > 0 || d.children[i].type == 'button'){
                    
                    switch(d.children[i].type){
                        case 'radiobutton':
                            d.children[i].value = returnBoolean(currentXMLVal);
                            break;
                         case 'checkbox':
                            d.children[i].value = returnBoolean(currentXMLVal);
                              if( d.children[i].name == 'useRefFile' && dvar.useRefFile.value){
                                  refFile = new File(x.presets.preset[n].child('refName'));

                                  if(refFile.exists){
                                      refXML = new XML(readXMLFile(refFile));
                                      refSame ()
                                        }//end if for refFile.exists
                                    }//end if for detecting if refFile was set in preferences                            
                            break;
                        case 'edittext':
                            d.children[i].text = currentXMLVal;
                            break;
                        case 'slider':
                            d.children[i].value = parseFloat(currentXMLVal);
                            break;
                        case 'dropdownlist':
                            varHold = false;
 
                          if(x.presets.preset[n].child(d.children[i].name).@selecIndex.toString() == 'null'){d.children[i].selection = null}
                          else{d.children[i].selection = parseInt(x.presets.preset[n].child(d.children[i].name).@selecIndex)};

                          break;
                          };//end switch else

                   };//end if to see if there is a good value from the XML
               
                };//end if for UI control having name
            };//end else for if child is container or control
        };//end for loop 
 };//end function setUIvar
 
 //function returns a boolean value.  Values stored in XML are returned as strings, so they need to be converted back to boolean values.
function returnBoolean(b){
	if(b == 'true'){return true}
	else{return false}
	};

//Function resets the values of the preset list when items are added or deleted.
function setPresetList(){
         presetList = new Array();
        dvar.presetsDbx.removeAll();
        for(var i=0;i<prefXML.presets.children().length();i++){dvar.presetsDbx.add('item',prefXML.presets.children()[i].@presetName)}
};//end function setPresetList

/////////////////////////////////////////////////Code for Fill///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//lines of code used by most the deco scripts - no point it having lots of duplicate lines of code.
function patternBlend(){

        //Switch for blend
        switch(parseInt(dvar.patternBlendDbx.selection)){
            case 0:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendNormal)';n++
                break;
            case 1:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendDissolve)';n++
                break;
            case 3:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendDarken)';n++
                break;
            case 4:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendMultiply)';n++
                break;
            case 5:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendColorBurn)';n++
                break;
            case 6:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendLinearBurn)';n++
                break;
            case 7:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendDarkerColor)';n++
                break;
            case 9:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendLighten)';n++
                break;
            case 10:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendScreen)';n++
                break;
            case 11:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendColorDodge)';n++
                break;
            case 12:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendLinearDodge)';n++ 
                break;
            case 13:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendLighterColor)';n++
                break;
            case 15:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendOverlay)';n++
                break;
            case 16:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendSoftLight)';n++
                break;
            case 17:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendHardLight)';n++ 
                break;
            case 18:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendVividLight)';n++
                break;
            case 19:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendLinearLight)';n++
                break;
            case 20:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendPinLight)';n++ 
                break;
            case 21:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendHardMix)';n++
                break;
            case 23:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendDifference)';n++ 
                break;
            case 24:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendExclusion)';n++ 
                break;
            case 25:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendSubtraction)';n++ 
                break;
            case 26:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendDivide)';n++ 
                break;
            case 28:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendHue)';n++ 
                break;
            case 29:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendSaturation)';n++ 
                break;
            case 30:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendColor)';n++ 
                break;
            case 31:
                a[n] = 'pattern.setParameter (kpsPatternBlendMode, kpsBlendLuminosity)';n++ 
                break;
                        
            };//end switch
        
    
    };//end function patternBlend
function commonVarsToArray(){
    a[n] = 'var refSizeFactor, refSizeShift'; n++
    if(dvar.refSize.value && dvar.useRefFile.value){
        var refSizeFactor = (parseFloat(dvar.refSizeMax.text)-parseFloat(dvar.refSizeMin.text))
        var refSizeShift = parseFloat(dvar.refSizeMin.text)
        a[n] = 'refSizeFactor =' + refSizeFactor; n++
        a[n] = 'refSizeShift =' + refSizeShift; n++
    }//end if
    a[n] = 'var colorCount = 0'; n++
    a[n] = 'var useRefFile =' + dvar.useRefFile.value; n++
    a[n] = 'var assignColor =' + dvar.assignColor.value; n++
    a[n] = 'var refSize =' + dvar.refSize.value; n++
    a[n] = 'var refRotate = '+ dvar.refRotate.value ;n++
    a[n] = 'var limitRotation = '+ dvar.limitRotation.value ;n++
    a[n] = 'var limitRotationAngle = '+ dvar.limitRotationEtxt.text ;n++
    
    a[n] = 'var fillAll = '+ dvar.fillAll.value ;n++
    a[n] = 'var fillBlack = '+ dvar.fillBlack.value ;n++
    a[n] = 'var fillWhite = '+ dvar.fillWhite.value ;n++
    a[n] = 'var fillRange = '+ dvar.fillRange.value ;n++
    a[n] = 'var fillMin = '+ Number(dvar.fillMin.text) ;n++
    a[n] = 'var fillMax = '+ Number(dvar.fillMax.text) ;n++
    
    a[n] = 'var cyanRef, magentaRef, yellowRef, blackRef, refX, refY'; n++
    a[n] = 'var cyanRef2, magentaRef2, yellowRef2, blackRef2'; n++
    a[n] = 'var refX = refY = 0'; n++
    a[n] = 'var xSampleSize = ' + parseInt(dvar.xSampleSize.text); n++
    a[n] = 'var ySampleSize = ' + parseInt(dvar.ySampleSize.text); n++

    a[n] = 'var scale = '+ dvar.patternScale.text ;n++
    
    if(dvar.refSize.value){
        a[n] = 'var refSizeMin = '+ dvar.refSizeMin.text ;n++
        a[n] = 'var refSizeMax = '+ dvar.refSizeMax.text ;n++
        
        }
    
    a[n] = 'var test = .1';n++
    a[n] = 'var startStepAdj = -1';n++
    
    a[n] = 'var cyanAlt = ' + dvar.cyanAlt.value;n++
    a[n] = 'var magentaAlt = ' + dvar.magentaAlt.value;n++
    a[n] = 'var yellowAlt = ' + dvar.yellowAlt.value;n++
    a[n] = 'var densAlt = ' + dvar.densAlt.value;n++
    
    a[n] = 'var cyanVal = 0;var magentaVal = 0; var yellowVal = 0; var densVal = 0';n++
    
    a[n] = 'var cyanOffset = 0';n++
    a[n] = 'var magentaOffset = 0';n++
    a[n] = 'var yellowOffset = 0';n++
    a[n] = 'var densOffset = 0';n++

    a[n] = 'var cyanStep = ' + dvar.cyanStep.text; n++
    a[n] = 'var cyanLimit = ' + dvar.cyanStart.text; n++
    a[n] = 'var magentaStep = ' + dvar.magentaStep.text; n++
    a[n] = 'var magentaLimit = ' + dvar.magentaStart.text; n++
    a[n] = 'var yellowStep = ' + dvar.yellowStep.text; n++
    a[n] = 'var yellowLimit = ' + dvar.yellowStart.text; n++
    a[n] = 'var densStep = ' + dvar.densStep.text; n++
    a[n] = 'var densLimit = ' + dvar.densityStart.text; n++
    
    a[n] = 'if(cyanStep > 0){var cyanVal = cyanLimit}'; n++
    a[n] = 'if(cyanStep < 0){var cyanVal = 1}'; n++
    
    a[n] = 'if(magentaStep > 0){var magentaVal = magentaLimit}'; n++
    a[n] = 'if(magentaStep < 0){var magentaVal = 1}'; n++
    
    a[n] = 'if(yellowStep > 0){var yellowVal = yellowLimit}'; n++
    a[n] = 'if(yellowStep < 0){var yellowVal = 1}'; n++
    
    a[n] = 'if(densStep > 0){var densVal = densLimit}'; n++
    a[n] = 'if(densStep < 0){var densVal = 1}'; n++
    
    a[n] = 'if(cyanStep != 0){cyanOffset = 1}';n++    
    a[n] = 'if(magentaStep !=0){magentaOffset = 1}';n++    
    a[n] = 'if(yellowStep !=0){yellowOffset = 1}';n++
    a[n] = 'if(densStep !=0){densOffset = 1}';n++ 
   
    a[n] = 'var colorRandomness = ' + dvar.colorJit.text; n++
    a[n] = 'var brightnessRandomness = ' + dvar.brightJit.text; n++
    
    if(parseInt(dvar.scriptDbx.selection == 4)){a[n] = 'rand.seed = Math.random()*123456'; n++}
    else{a[n] = 'rand.seed = 1'}; n++
    
    a[n] = 'rand2.seed = ' + seed2Temp + ';var seed2'; n++
    a[n] = 'function rand2(){rand2.seed = (rand2.seed*9301+49297)%233280;'; n++
    a[n] = 'return rand2.seed/(233280.0)};'; n++
    a[n] = 'function rand(){rand.seed = (rand.seed*9301+49297) % 233280;'; n++
    a[n] = 'return rand.seed/(233280.0)};'; n++    
    a[n] = 'var outputSize = RenderAPI.getParameter(kpsSize)'; n++
    a[n] = 'var outputOrigin = RenderAPI.getParameter(kpsOrigin)'; n++
    a[n] = 'var pattern = RenderAPI.getParameter(kpsPattern)'; n++
    a[n] = 'var patternSize = pattern.getParameter(kpsSize)'; n++
   
    if(parseInt(dvar.scriptDbx.selection) != 5){
        if(dvar.spPrecent.value){
            a[n] = 'patternSize.x  += patternSize.x * ' + dvar.spaceX.text + '/100'; n++
            a[n] = 'patternSize.y  += patternSize.y * ' + dvar.spaceY.text + '/100'; n++             
            }
        else{
            a[n] = 'patternSize.x  += ' + dvar.spaceX.text; n++
            a[n] = 'patternSize.y  += ' + dvar.spaceY.text; n++    
            }
    }//end if
    patternBlend()
    }

function includeRefFile(){
    a[n] = 'var refArray = new Array()'; n++

    for(var i = 0;i<refXML.lines.children().length();i++){
        if(refXML.lines.children()[i] == 'new'){a[n] = 'refArray[' + refXML.lines.children()[i].@y + '] = new Array()'; n++}
        else{a[n] = 'refArray[' + refXML.lines.children()[i].@y + '][' + refXML.lines.children()[i].@x + '] = "' + refXML.lines.children()[i] + '"'; n++};
        }
    };//end function includeRefFile

function colorLines(){

    a[n] = 'seed2 = rand2();'; n++
    if(parseInt(dvar.scriptDbx.selection != 4)){a[n] = 'rand()'; n++}
    a[n] = 'var rc = colorRandomness'; n++
    a[n] = 'var br = 1 - brightnessRandomness + rand()*brightnessRandomness'; n++
    
    a[n] = 'cyanVal = cyanVal + cyanStep'; n++
    a[n] = 'magentaVal = magentaVal + magentaStep'; n++
    a[n] = 'yellowVal = yellowVal + yellowStep'; n++
    a[n] = 'densVal = densVal + densStep'; n++
    
    a[n] = 'if(cyanAlt && (cyanVal < cyanLimit || cyanVal > 1)){cyanStep *= -1}'; n++
    a[n] = 'if(magentaAlt == 1 && (magentaVal < magentaLimit || magentaVal > 1)){magentaStep*=-1}'; n++
    a[n] = 'if(yellowAlt == 1 && (yellowVal < yellowLimit || yellowVal > 1)){yellowStep*=-1}'; n++
    a[n] = 'if(densAlt == 1 && (densVal < densLimit || densVal > 1)){densStep*=-1}'; n++
    
    a[n] = 'if(useRefFile){'; n++
        a[n] = 'try{'; n++
        
            a[n] = 'if(refX<0){refX = 0}'; n++
            a[n] = 'if(refY<0){refY = 0}'; n++
            a[n] = 'if(refX>=refArray[0].length){refX = refArray[0].length - 1}'; n++
            a[n] = 'if(refY>=refArray.length){refY = refArray.length - 1}'; n++
            
            a[n] = 'if(refArray[refY][refX] != "null"){'; n++
            
                a[n] = 'var refColorLevel =' + dvar.refColorLevel.text/100; n++
                a[n] = 'var refBlackLevel =' + dvar.refBlackLevel.text/100; n++
                a[n] = 'cyanRef2 = parseFloat(refArray[refY][refX].split("~")[0])'; n++
                a[n] = 'cyanRef = refColorLevel *cyanRef2'; n++
                a[n] = 'magentaRef2 = parseFloat(refArray[refY][refX].split("~")[1])'; n++
                a[n] = 'magentaRef = refColorLevel *magentaRef2'; n++
                a[n] = 'yellowRef2 = parseFloat(refArray[refY][refX].split("~")[2])'; n++
                a[n] = 'yellowRef = refColorLevel *yellowRef2'; n++
                a[n] = 'blackRef2 = parseFloat(refArray[refY][refX].split("~")[3])'; n++
                a[n] = 'blackRef = refBlackLevel *blackRef2'; n++
                a[n] = '}'; n++//end if
            a[n] = 'else{cyanRef = cyanRef2 = magentaRef = magentaRef2 = yellowRef = yellowRef2 = blackRef = blackRef2 = 0}'; n++
        a[n] = '}'; n++//end try
        a[n] = 'catch(e){Engine.message("The Reference File was not made properly.")'; n++
        a[n] = 'break;}'; n++
    a[n] = '}'; n++//end if
    
    a[n] = 'if(!useRefFile || !assignColor){RenderAPI.Color (kFillColor, br *(1 - rc + rand()*rc) + cyanVal - cyanOffset + densVal-densOffset, br*(1 - rc + rand()*rc) + magentaVal - magentaOffset + densVal-densOffset, br*(1 - rc + rand()*rc) + yellowVal - yellowOffset + densVal-densOffset)}'; n++//do nothing
    a[n] = 'if(useRefFile && assignColor){RenderAPI.Color (kFillColor, 1-cyanRef/100 - blackRef/300, 1-magentaRef/100 - blackRef/300, 1-yellowRef/100 - blackRef/300)}'; n++     
      
    }

function sizeLines(){

        a[n] = 'try{'; n++
        a[n] = 'var refScale = refSizeFactor * (cyanRef2 + magentaRef2 + yellowRef2 + blackRef2)/300 + refSizeShift'; n++
        a[n] = 'if(refScale <.1){refScale = .1}'; n++
        a[n] = 'RenderAPI.scale(scale * refScale, scale * refScale)'; n++;
        a[n] = '}'; n++;
        a[n] = 'catch(e){}'; n++;
    };//end function

function rotateLines(){
    
    if(dvar.limitRotation.value){
        a[n] = 'RenderAPI.rotate(Math.floor (((cyanRef2 + magentaRef2 + yellowRef2 + blackRef2)*'+rLimit+')/limitRotationAngle) * limitRotationAngle)'; n++
    }
    else{a[n] = 'RenderAPI.rotate(Math.floor (cyanRef2 + magentaRef2 + yellowRef2 + blackRef2)*'+rLimit+')'; n++}
    };//end function rotateLines.

function renderLines(){
    a[n] = 'if(seed2>' +minValTemp +' && seed2< ' +maxValTemp + '){'; n++
            a[n] = 'if(!useRefFile ){pattern.render(RenderAPI)}'; n++
            //a[n] = 'if(useRefFile && refArray[refY][refX] != "null"){pattern.render(RenderAPI)}'; n++          // just black?   
            
            a[n] = 'if(useRefFile && refArray[refY][refX] != "null"){'; n++
            a[n] = 'if(fillAll){pattern.render(RenderAPI)}'; n++
            a[n] = 'else if(fillBlack && blackRef>50){pattern.render(RenderAPI)}'; n++
            a[n] = 'else if(fillWhite && blackRef<50){pattern.render(RenderAPI)}'; n++
            a[n] = 'else if(fillRange && blackRef>=fillMin && blackRef <= fillMax){pattern.render(RenderAPI)}'; n++
            a[n] = '}'; n++
           // a[n] = 'if(useRefFile && refArray[refY][refX] != "null"){pattern.render(RenderAPI)}'; n++             
        a[n] = '}'; n++
    }
/*
function renderLinesSym(){
    a[n] = 'if(seed2>' +minValTemp +' && seed2< ' +maxValTemp + '){'; n++
        a[n] = 'if(useRefFile == 2){'; n++
            a[n] = 'if(blackRef >0){pattern.render(api)}'; n++
            a[n] = '}'; n++
        a[n] = 'else{pattern.render(api)}'; n++
    a[n] = '}'; n++
    }
*/
function brickScriptToArray(){
    a = new Array()
    n = 0
    commonVarsToArray()
    includeRefFile()
    a[n] = 'var offset = ' + dvar.brickOffset.text; n++

    a[n] = 'var row = Math.floor( outputOrigin.y / patternSize.y )'; n++
    a[n] = 'var column = Math.floor( outputOrigin.x / patternSize.x )'; n++

    a[n] = 'for (var y = patternSize.y/2; y < outputSize.y + patternSize.y;  y+= patternSize.y, row++){'; n++
    a[n] = 'RenderAPI.pushMatrix()'; n++
    a[n] = 'var x = patternSize.x/2'; n++
   
    a[n] = 'if ( (row%2) == 1){'; n++
    a[n] = 'x -= patternSize.x * offset'; n++

    a[n] = '}'; n++
    a[n] = 'for (var c = column; x < outputSize.x + patternSize.x * (1 + offset);  x+= patternSize.x, c ++){'; n++
    a[n] = 'RenderAPI.pushMatrix()'; n++

    a[n] = 'rand.seed =  row * 1234567 + c * 7654321'; n++
    a[n] = 'refX = Math.floor(x /xSampleSize)'; n++
    a[n] = 'refY = Math.floor(y /ySampleSize)'; n++ 
    colorLines()
    
    if(dvar.refSize.value && dvar.useRefFile.value){
        sizeLines()
        }
    else if(dvar.sizeJitCbx.value){a[n] = 'RenderAPI.scale(rand()*0.1 + scale)'; n++};//added scale used to be 1
    else{a[n] = 'RenderAPI.scale(scale, scale)'; n++};//line added
    
    if(dvar.useRefFile.value && dvar.refRotate.value){rotateLines() };
    else if(dvar.angleJitCbx.value){a[n] = 'RenderAPI.rotate(' + dvar.angleEtxt.text + ' + Math.floor(rand()* ' + dvar.angleAmtEtxt.text + ') / 25);// 60 distinct rotations - to help cache'; n++};
    a[n] = 'RenderAPI.translate(x, y)';n++
    renderLines ()
    
    a[n] = 'RenderAPI.popMatrix();'; n++
    a[n] = '}'; n++
    a[n] = 'RenderAPI.popMatrix()'; n++
    a[n] = '}'; n++
    
    
    return a
    };//end function for brick script

////////////////////////////////////////////////////////////////////////////////////////

//Cross Weave script
function weaveScriptToArray(){
    a = new Array()
    n = 0
    commonVarsToArray()
    includeRefFile()
    
    a[n] = 'patternSize *= scale;';n++
    a[n] = 'var sizeStep = (patternSize.x + patternSize.y) / 2';n++
    
    a[n] = 'var adjOutputSize = Math.ceil (Math.sqrt (Math.pow (outputSize.x, 2)+Math.pow (outputSize.y, 2))+ (patternSize.x + patternSize.y)*2)';n++
    a[n] = 'var origAngle =' + dvar.crossAngle.text;n++
    a[n] = 'var a225 = 225*Math.PI/180';n++
    a[n] = 'var angleRad = origAngle*Math.PI/180';n++
    a[n] = 'var angle90Rad = (90+ origAngle)*Math.PI/180';n++
    a[n] = 'var patternAngle = 90';n++
    a[n] = 'var startX = Math.cos(angleRad + a225)*adjOutputSize/2 + outputSize.x/2';n++
    a[n] = 'var startY = Math.sin(angleRad + a225)*adjOutputSize/2 + outputSize.y/2';n++
    a[n] = 'var rowStepSizeX =Math.sin (angleRad)*sizeStep';n++
    a[n] = 'var colStepSizeX =Math.cos (angleRad)*sizeStep';n++
    a[n] = 'var colStepSizeY = Math.tan(angleRad)*colStepSizeX';n++
    a[n] = 'var rowStepSizeY = Math.tan(angle90Rad)*rowStepSizeX';n++
    
    a[n] = 'var row = Math.ceil( adjOutputSize / sizeStep)';n++
    a[n] = 'var column = Math.ceil( adjOutputSize/ sizeStep)';n++
    
    a[n] = 'if(origAngle%90 == 0){';n++
        a[n] = 'rowStepSizeX = colStepSizeX = colStepSizeY = rowStepSizeY = sizeStep;';n++
        a[n] = 'startX = startY = -patternSize.x - patternSize.y}';n++
    
    a[n] = 'var x = startX';n++
    a[n] = 'var y = startY';n++
    
    a[n] = 'for (var yn = 0; yn <= row;  yn++){';n++
        a[n] = 'x-= yn%2==1 ? colStepSizeX  :0';n++
        a[n] = 'if(origAngle%90 !=0){y-= yn%2==1 ? colStepSizeY  :0}';n++
        a[n] = 'patternAngle = 90';n++
    
        a[n] = 'RenderAPI.pushMatrix()';n++  
        a[n] = 'var col = column';n++
        
        a[n] = 'for (var xn = 0; xn <=column;  xn++,col++){';n++
            a[n] = 'rand.seed = row * 1234567 + col * 7654321';n++
            
            a[n] = 'patternAngle = (patternAngle + 90)%180';n++
            if(dvar.crossRand.value){a[n] = 'patternAngle += Math.floor(Math.random ()*2) *180';n++};

            a[n] = 'RenderAPI.pushMatrix()';n++  
            a[n] = 'RenderAPI.translate(x, y)';n++ 
            
    if(dvar.refSize.value && dvar.useRefFile.value){
        sizeLines()
        }
    else{a[n] = 'RenderAPI.scale(scale, scale)'; n++};//line added            
            
            a[n] = 'RenderAPI.rotate(patternAngle + origAngle)';n++
            
            a[n] = 'refX = Math.floor(x /xSampleSize)'; n++
            a[n] = 'refY = Math.floor(y /ySampleSize)'; n++             
            colorLines()
   
            renderLines ()
            a[n] = 'x +=colStepSizeX';n++ 
            a[n] = 'if(origAngle%90 !=0){y += colStepSizeY}';n++
            
            a[n] = 'RenderAPI.popMatrix()';n++
            a[n] = '}';n++
            
        a[n] = 'if(origAngle%90 !=0){';n++
            a[n] = 'x=startX - rowStepSizeX*yn';n++
            a[n] = 'y=startY - rowStepSizeY *yn}';n++
        a[n] = 'else{';n++
            a[n] = 'x=startX';n++
            a[n] = 'y+= sizeStep}';n++
        a[n] = 'RenderAPI.popMatrix()}'
    
    return a
    
    };//end function for cross weave


///////////////////////////////////////////////////////////////////////////////////
//Spiral
function spiralScriptToArray(){
    a = new Array()
    n = 0
    
     a[n] = 'var offset = ' + dvar.spiralOffset.text; n++
     a[n] = 'var angleFactor = ' + dvar.angleFactor.text; n++
     a[n] = 'var maxElements = 10000'; n++
    commonVarsToArray();
    
    a[n] = 'var angle = ' + dvar.spiralFillAngle.text; n++
    a[n] = 'var patAngle = ' + dvar.spiralPatAngle.text; n++
    a[n] = 'var angleStep'; n++
    a[n] = 'RenderAPI.translate(outputSize.x / 2, outputSize.y / 2)'; n++
    a[n] = 'var num = 0'; n++
    a[n] = 'var diagonal = Math.sqrt(outputSize.x*outputSize.x + outputSize.y*outputSize.y) * 0.5';n++ 
    a[n] = '+ Math.sqrt(patternSize.x * patternSize.x + patternSize.y *patternSize.y)  * 0.5'; n++
    a[n] = 'for (var radius = 0; Math.abs(radius) <  diagonal ; ){'; n++
    a[n] = 'radius = patternSize.y/2 + ((patternSize.y-1+offset) / 360) * angle  // In one revolution (360 degrees) we want to add patternSize.y to the radius'; n++
    a[n] = 'angleStep = 360 / ( 6.28 * (radius - patternSize.y/2)/ (patternSize.x)) * angleFactor'; n++
    a[n] = 'RenderAPI.pushMatrix()'; n++
    colorLines()
    a[n] = 'RenderAPI.translate(-outputSize.x / 2, -outputSize.y / 2)'; n++
    a[n] = 'RenderAPI.rotate(angle)'; n++
    a[n] = 'RenderAPI.translate(outputSize.x / 2, outputSize.y / 2)'; n++
    a[n] = 'RenderAPI.translateRel(0, radius)   // translate relative to the rotated frame'; n++
    a[n] = 'RenderAPI.scale (scale, scale)'; n++
    a[n] = 'RenderAPI.rotate( - angle + 2 * Math.floor(0.5+angle/2)+patAngle)'; n++
    a[n] = 'if(seed2>' +minValTemp +' && seed2< ' +maxValTemp + '){pattern.render(RenderAPI)}'; n++
    a[n] = 'RenderAPI.popMatrix()'; n++
    a[n] = 'angle += angleStep'; n++
    a[n] = 'if (++num == maxElements)'; n++
    a[n] = 'break'
    a[n] = '}'
    
    return a
    };//end spiral

function randomScriptToArray(){
    a = new Array()
    n = 0
    
    a[n] = 'var density = ' + dvar.randDens.text; n++
    a[n] = 'var patternScaleFrom =' + dvar.randMinScale.text; n++
    a[n] = 'var patternScaleTo =' + dvar.randMaxScale.text; n++
    commonVarsToArray();
    includeRefFile ()
    

    a[n] = 'Math.random(1) // sets the seed';n++
    a[n] = 'var sizes = new Array()';n++
    ////////////Push various sizes to array
    a[n] = 'sizes.push (5)';n++
    a[n] = 'sizes.push (2)';n++
    //a[n] = 'sizes.push (1)';n++
    //a[n] = 'sizes.push (.5)';n++
    // determine the number approximately based on size of the element and filled area
    if(dvar.randUseDens.value){
        a[n] = 'var num = ((outputSize.x + patternSize.x) * (outputSize.y + patternSize.y)) / (patternSize.x * patternSize.y) * density';n++
        a[n] = 'if (num < 1){num = 1}';n++
        a[n] = 'for (var n = 0; n < num; n++){';n++}
    else{a[n] = 'for (var n = 0; n < ' + dvar.randDens.text + '; n++){';n++}
    
    a[n] = 'RenderAPI.pushMatrix()';n++
    a[n] = 'var scale = (patternScaleFrom + (patternScaleTo - patternScaleFrom) * Math.random() )';n++
    a[n] = 'var spanx = outputSize.x + patternSize.x * scale';n++
    a[n] = 'var spany = outputSize.y + patternSize.y * scale';n++
    a[n] = 'var x =  -patternSize.x * scale * 0.5 + spanx * Math.random()';n++
    a[n] = 'var y =  -patternSize.y * scale * 0.5 + spany * Math.random()';n++
    
    a[n] = 'refX = Math.floor(x /xSampleSize)'; n++
    a[n] = 'refY = Math.floor(y /ySampleSize)'; n++ 
    
    a[n] = 'RenderAPI.translate(x, y)';n++
    a[n] = 'RenderAPI.scale(scale, scale)';n++
    switch(parseInt(dvar.randRotateDbx.selection)){
        case 0:
            a[n] = 'var rotate = 360/30 * Math.floor(Math.random() * 30) // 30 distinct rotations';n++
            break;
        case 1:
            a[n] = 'var rotate = 0';n++
            break;
        case 2:
            a[n] = 'var rotate = ' + dvar.randCusAng.text;n++
            break;
        case 3:
            if(dvar.limitRotation.value){
                a[n] = 'var rotate = Math.floor (((cyanRef2 + magentaRef2 + yellowRef2 + blackRef2)*'+rLimit+')/limitRotationAngle) * limitRotationAngle'; n++
            }
            else{a[n] = 'var rotate = Math.floor (cyanRef2 + magentaRef2 + yellowRef2 + blackRef2)*' + rLimit; n++}        
            break;
            }//end switch
        if(dvar.randAngJit.value){a[n] = 'rotate += Math.random()*8-16';n++}
    a[n] = 'RenderAPI.rotate(rotate)';n++
    colorLines ()
    renderLines ()
    a[n] = 'RenderAPI.popMatrix()}';
    
    
    return a
    };//enf function random

function symmetryScriptToArray(){
    a = new Array()
    n = 0

    a[n] = 'Initial.isymmetryType = ' + symPatSel;n++
    // Pattern translation.
    // By modifying this value you will change the layout of the pattern.
    // Try the following pairs of values: 0, 0 or 0, 0.75 or 0.75, 0
    // Note that the behavior is different when your pattern is thin in x or y .
    a[n] = 'var patternTranslationX = ' + dvar.transX.text;n++   // The default is 0.75
    a[n] = 'var patternTranslationY = ' + dvar.transY.text;n++   // The default is 0.75    
    commonVarsToArray()
    a[n] = 'function PatternModule()';n++
    a[n] = '{';n++
    a[n] = '}';n++
    a[n] = 'PatternModule.prototype.render = function (api){';n++
    a[n] = 'api.pushMatrix()';n++
    a[n] = 'api.translateRel(patternSize.x * patternTranslationX, patternSize.y * patternTranslationY)';n++
    a[n] = 'var currentFrame = api.getFrame()';n++
    a[n] = 'rand.seed = Math.floor(currentFrame.position().x + 100000) * 1237 + Math.floor(currentFrame.position().y + 100000) * 7654321';n++
    colorLines();
    a[n] = 'pattern.render(api)';n++

    a[n] = 'api.popMatrix()}'; n++
    /////////////
    a[n] = 'var patternModule = new PatternModule();'; n++
    // Symmetry - module should be added to the system before modules that 
    // are part of the symmetry
    a[n] = 'var symmetry = new Symmetry;'; n++
    a[n] = 'var frameZero = new Frame2();'; n++
    a[n] = 'var frameOrigin = new Frame2();'; n++
    a[n] = 'frameOrigin.setPosition(0, 0);'; n++
    a[n] = 'frameOrigin.rotateDeg(0.0);'; n++
    //symmetry.frame = frameOrigin;  // no need to set the frame if it is a default frame at position (0,0) and no rotation
    a[n] = 'function Initial () {}'; n++
    a[n] = 'var initial = new Initial()'; n++
    a[n] = 'Initial.variableUpdated = function (varname){'; n++
    a[n] = 'switch (Initial.isymmetryType){'; n++
    a[n] = 'case 0:'; n++
    a[n] = 'symmetry.set(kSymmetryLineReflection, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 1:'; n++
    a[n] = 'symmetry.set(kSymmetryPointReflection, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 2:'; n++
     // Type, number of elements around the center, frame specifying local position of an element, optional center of rotation (must be a point)
    a[n] = 'symmetry.set(kSymmetryRotation, 4, frameZero);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 3:'; n++
    a[n] = 'symmetry.set(kSymmetryTranslation, 4, 1.0, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 4:'; n++
    a[n] = 'symmetry.set(kSymmetryGlideReflection, 5, 4.0, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    // Number, initial angle, angle increment, initial scale, scale ratio
    a[n] = 'case 5:'; n++
    a[n] = 'symmetry.set(kSymmetryDilatation, 600, 1.0, 1.0 / 1.01, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 6:'; n++
    a[n] = 'symmetry.set(kSymmetryDilativeRotation, 600, 0.0, kFibonacciAngleInDegrees, 1.0, 1.0 / 1.01, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 7:'; n++
    a[n] = 'symmetry.set(kSymmetryDilativeRotation, 200, 0.0, kFibonacciAngleInDegrees, 0.0333, 1.02, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 8:'; n++
    a[n] = 'symmetry.set(kSymmetryInfiniteDilativeRotation, 0.0, kFibonacciAngleInDegrees, 0.5, 1.01, frameZero, kTransformToLocal); '; n++
    a[n] = 'break;}'; n++
    //////////////////////////
    a[n] = 'var uStep = patternSize.y * 1.25;';n++
    a[n] = 'var vStep = patternSize.x * 1.25;';n++
    // The Frieze tilings (1D tilings on an infinite line
    a[n] = 'switch (Initial.isymmetryType){';n++
    a[n] = 'case 9:'; n++
    a[n] = 'symmetry.set(kSymmetryFriezeTranslation, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 10:'; n++
    a[n] = 'symmetry.set(kSymmetryFriezeGlideReflection, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 11:'; n++
    a[n] = 'symmetry.set(kSymmetryFriezeTranslationLineReflection, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 12:'; n++
    a[n] = 'symmetry.set(kSymmetryFriezeTranslationMirrorReflection, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 13:'; n++
    a[n] = 'symmetry.set(kSymmetryFriezeTranslationPointReflection, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 14:'; n++
    a[n] = 'symmetry.set(kSymmetryFriezeTranslationDoubleReflection, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 15:'; n++
    a[n] = 'symmetry.set(kSymmetryFriezeGlideReflectionRotation, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;}'; n++
    /////////////////////////////
    a[n] = 'uStep = uStep //* 2.5;';n++//see about add UI for this
    a[n] = 'vStep = vStep //* 2.5';n++//see about add UI for this
    // The Wallpaper tilings 2D tilings on an infinite plane
    a[n] = 'switch (Initial.isymmetryType){';n++
    a[n] = 'case 16:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperP1, uStep, vStep, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 17:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperP2, uStep, vStep, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 18:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperPM, uStep, vStep, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 19:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperPG, uStep, vStep, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;}'; n++
    //////////////////////////
    a[n] = 'uStep = uStep * 1.5;'; n++
    a[n] = 'vStep = vStep * 1.5;'; n++
    a[n] = 'switch (Initial.isymmetryType){';n++
    a[n] = 'case 20:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperPMM, uStep, vStep, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 21:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperCM, uStep, vStep, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;}'; n++
    //////////////////////////////////
    a[n] = 'uStep = uStep * 0.75;'; n++
    a[n] = 'vStep = vStep * 0.75;'; n++
    a[n] = 'switch (Initial.isymmetryType){';n++
    a[n] = 'case 22:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperPMG, uStep, vStep, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 23:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperPGG, uStep, vStep, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 24:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperCMM, uStep, vStep, frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 25:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperP4, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 26:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperP4M, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 27:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperP4G, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;}'; n++
    ////////////////////////////////////////////
    a[n] = 'uStep = uStep * 1.75;'; n++
    a[n] = 'vStep = vStep * 1.75;'; n++
    a[n] = 'switch (Initial.isymmetryType){';n++
    a[n] = 'case 28:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperP3, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 29:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperP3M1, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 30:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperP31M, Math.max(uStep, vStep), frameZero, kTransformToLocal); '; n++
    a[n] = 'break;'; n++
    a[n] = 'case 31:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperP6,  Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;'; n++
    a[n] = 'case 32:'; n++
    a[n] = 'symmetry.set(kSymmetryWallpaperP6M, Math.max(uStep, vStep), frameZero, kTransformToLocal);'; n++
    a[n] = 'break;}'; n++
    a[n] = 'return 1}'; n++
    // set the symmetry type
    a[n] = 'Initial.variableUpdated("isymmetryType")'; n++
    a[n] = 'Engine.addModule (symmetry)'; n++
    a[n] = 'Engine.addModule (patternModule)'; n++
    // Add to the symmetry
    a[n] = 'symmetry.addModule (patternModule)'; n++
    a[n] = 'if (Initial.isymmetryType >= 16)'; n++
    // Setting the bounding box like this will insure that neighboring fills are aligned for 2D tilings
    a[n] = 'Engine.setSceneBBox (outputOrigin.x, outputOrigin.x + outputSize.x,  outputOrigin.y,  outputOrigin.y + outputSize.y)'; n++
    a[n] = 'else{'; n++
    // Other symmetries will be centered around the center of the selection bounding box
    a[n] = 'Engine.setSceneBBox (-outputSize.x/2,  outputSize.x/2,  -outputSize.y/2,  outputSize.y/2)}'; n++

    return a
    };//end symmetry

///////////////////////////////////////////////////////////////////////////////////////
//Random Border Fill

function randomBorderScriptToArray(){
    a = new Array()
    n = 0
    
    a[n] = 'var randNum = .23'; n++
    a[n] = 'var oval = ' + dvar.oval.value; n++
    a[n] = 'var density = ' + dvar.randBrdDens.text; n++
    a[n] = 'var bSize = ' + dvar.bSize.text; n++
    a[n] = 'var rotateMethod = ' + parseInt(dvar.randBrdRotateDbx.selection); n++
    
    
    a[n] = 'var patternScaleFrom =' + dvar.randBdrMinScale.text; n++
    a[n] = 'var patternScaleTo =' + dvar.randBdrMaxScale.text; n++
    commonVarsToArray();
    
    a[n] = 'var mV = new Object();';n++//object to hold all math variables
    a[n] = 'var xToggle = true';n++
    a[n] = 'var yToggle = true';n++
    a[n] = 'var scale = 1';n++
    a[n] = 'if (patternSize.x == 1 && patternSize.y == 1){';n++
    a[n] = 'scale = 20';n++
    a[n] = 'patternSize *= scale';n++
    a[n] = 'rotateMethod = 0}';n++// 1x1 patterns that are scaled up do not rotate gracefully
    
    a[n] = 'mV.maxPattern = Math.max(patternSize.x,patternSize.y)';n++
    a[n] = 'mV.depth = Math.max(patternSize.x,patternSize.y)/2';n++
    

    a[n] = 'mV.boxX = outputSize.x - Math.max(outputSize.x,outputSize.y)*bSize/50 + Math.sqrt (Math.pow(patternSize.x,2) + Math.pow(patternSize.y,2)) * .6 * patternScaleTo';n++//use mV.bL instead?
    a[n] = 'mV.boxY = outputSize.y - Math.max(outputSize.x,outputSize.y)*bSize/50 + Math.sqrt (Math.pow(patternSize.x,2) + Math.pow(patternSize.y,2)) * .6 * patternScaleTo';n++//use mV.bL instead?

    if(dvar.oval){a[n] = 'var num = (outputSize.x + outputSize.y) * bSize * 110 / (patternSize.x * patternSize.y) * density';n++}
    else{a[n] = 'var num = (outputSize.x + outputSize.y) * bSize * 80 / (patternSize.x * patternSize.y) * density';n++}
    
    a[n] = 'if (num < 1){num = 1}';n++
   
    ////////////////////////////////////////////
    a[n] = 'var x1, y1, whatSide'; n++
    a[n] = 'mV.maxAx = Math.max(mV.boxX,mV.boxY)/2'; n++//get max and min oval axises
    a[n] = 'mV.xAx = mV.boxX/2'; n++
    a[n] = 'mV.yAx = mV.boxY/2'; n++
    a[n] = 'mV.xDiff = (outputSize.x - mV.boxX) * .5'; n++
    a[n] = 'mV.yDiff = (outputSize.y - mV.boxY) * .5'; n++
    
    a[n] = 'mV.centerX = outputSize.x/2'; n++//center point of fill x value
    a[n] = 'mV.centerY = outputSize.y/2'; n++//center point of fill y value
    
    ///////////////////////////////////////////
    if(dvar.randBrdUseDens.value){a[n] = 'num *= (mV.depth / patternSize.x) / patternScaleFrom';n++}
    else{a[n] = 'num *= ' + dvar.randBrdDens.text;n++}
    
     
    a[n] = 'for (var n = 0; n <num; n++){';n++
    a[n] = 'RenderAPI.pushMatrix()';n++

    
    a[n] = 'whatEdge = Math.floor (rand() * 4)';n++//use this when doe
    a[n] = 'switch (whatEdge){';n++//for testing
    
    a[n] = 'case 0:  // top edge';n++
    a[n] = 'px = 0; py = 0 - mV.depth - mV.maxPattern;';n++
    a[n] = 'dx = 1; dy = 0;';n++
    a[n] = 'length = outputSize.x;';n++
    a[n] = 'angle = 270';n++
    a[n] = 'break;';n++
 
    a[n] = 'case 1:  // bottom edge';n++
    a[n] = 'px = outputSize.x; py = outputSize.y + mV.depth + mV.maxPattern;';n++
    a[n] = 'dx = -1; dy = 0;';n++
    a[n] = 'length = outputSize.x;';n++
    a[n] = 'angle = 90';n++
    a[n] = 'break;';n++

    a[n] = 'case 2:  // left edge';n++
    a[n] = 'px =  0 - mV.depth - mV.maxPattern; py = outputSize.y;';n++
    a[n] = 'dx = 0; dy = -1;';n++
    a[n] = 'length = outputSize.y;';n++
    a[n] = 'angle = 180';n++
    a[n] = 'break;';n++

    a[n] = 'case 3:  // right edge';n++
    a[n] = 'px = outputSize.x + mV.depth + mV.maxPattern; py = 0;';n++
    a[n] = 'dx = 0; dy = 1;';n++
    a[n] = 'length = outputSize.y;';n++
    a[n] = 'angle = 0';n++
    a[n] = 'break;';n++    
    a[n] = '}';n++
    
    if(dvar.useSeed.value){a[n] = 'var r = rand()';n++}
    else{a[n] = 'var r = Math.random()';n++}

    a[n] = 'var w = mV.depth * Math.pow(r, 2);';n++
    a[n] = 'var localScale = scale * (patternScaleFrom + (patternScaleTo - patternScaleFrom) * (1 - (w / mV.depth)) )';n++
    a[n] = 'var spanAlong = length + (patternSize.x * Math.abs(dx) + patternSize.y * Math.abs(dy)) * localScale';n++
    
    if(dvar.useSeed.value){a[n] = 'var l = spanAlong * rand();';n++}
    else{a[n] = 'var l = spanAlong * Math.random();';n++}
    
    a[n] = 'var x =  px + dx * l  - dy * w;';n++
    a[n] = 'var y =  py + dy * l + dx * w;';n++
    
    /////////////////////////////////////////////////////////////
    //oval addition
    a[n] = 'if(oval){';n++
    
        
        if(dvar.useSeed.value){a[n] = 'randNum = rand();';n++}
        else{a[n] = 'randNum = Math.random();';n++}                    
 
        a[n] = 'if((x > outputSize.x/2 - mV.xAx && x < outputSize.x/2 + mV.xAx && whatEdge <2) ||(y > outputSize.y/2 - mV.yAx && y < outputSize.y/2 + mV.yAx && whatEdge >1)){';n++//limits calculations to inside of oval
    
            
            a[n] = 'if(whatEdge < 2){';n++// select which side is random and covert x to quad point
                a[n] = 'x1 = x - mV.centerX';n++
                a[n] = 'mV.cA = Math.asin(x1/mV.maxAx)}';n++//get angle of x on ci

            a[n] = 'else{y1 = y - mV.centerY';n++// select which side is random and covert x to quad point
                a[n] = 'mV.cA = Math.asin(mV.maxAx/y1)';n++// end else
                a[n] = '}';n++// end else    

            a[n] = 'switch(whatEdge){';n++
                a[n] = 'case 0:';n++//top edge
                    a[n] = 'mV.eY = (-mV.yAx*Math.sqrt (1-Math.pow(x1/mV.xAx,2)) + mV.yAx + mV.yDiff )* randNum';n++
                    a[n] = 'y = mV.eY + outputSize.y/2 - mV.yAx - mV.yDiff';n++
                    a[n] = 'break;';n++
                a[n] = 'case 1:';n++//bottom edge
                    a[n] = 'mV.eY = (mV.yAx*Math.sqrt (1-Math.pow(x1/mV.xAx,2)) - mV.yAx - mV.yDiff) * randNum ';n++
                    a[n] = 'y = mV.eY + outputSize.y/2 + mV.yAx + mV.yDiff';n++         
                    a[n] = 'break;';n++
                a[n] = 'case 2:';n++//left edge     
                    a[n] = 'mV.eX = (-mV.xAx*Math.sqrt (1-Math.pow(y1/mV.yAx,2)) + mV.xAx + mV.xDiff) * randNum ';n++
                    a[n] = 'x = mV.eX +outputSize.x/2 - mV.xAx - mV.xDiff';n++
                      
                    a[n] = 'break;';n++
                a[n] = 'case 3:';n++//right edge
                    a[n] = 'mV.eX = (mV.xAx*Math.sqrt (1-Math.pow(y1/mV.yAx,2)) - mV.xAx - mV.xDiff) * randNum ';n++
                    //a[n] = '(mV.eX = mV.xAx*Math.sqrt (1-Math.pow(y1/mV.yAx,2)) - mV.xAx - mV.xDiff)* rand() ';n++
                    a[n] = 'x = mV.eX + outputSize.x/2 + mV.xAx + mV.xDiff';n++               
                    a[n] = 'break;';n++                    
            a[n] = '}';n++//end switch for sides
            

        a[n] = '}';n++//end if for if random value falls within oval
        
        a[n] = 'else if(whatEdge <2){';n++//end if for if random value falls within oval
            a[n] = '    y= (outputSize.y/4) * randNum;';n++//assign y
            a[n] = '    yToggle = yToggle == false;';n++
            
            a[n] = '    if(yToggle){//assign y';n++//assign y
            a[n] = '        y+= outputSize.y * .75  ;';n++
            a[n] = '    }';n++//end if for ytoggle
            a[n] = '    else{';n++//else for ytoggle
            a[n] = '    }';n++//end else for ytoggle
            
        a[n] = '}';n++//end else if <2
        a[n] = 'else{';n++//last else of else if
            a[n] = '    x= (outputSize.x/4) * randNum;';n++//assign y
            a[n] = '    xToggle = xToggle == false;';n++
            
            a[n] = '    if(xToggle){//assign x';n++//assign y
            a[n] = '        x+= outputSize.x * .75;';n++
            a[n] = '    }';n++//end if for ytoggle
            a[n] = '    else{';n++//else for ytoggle
            a[n] = '    }';n++//end else for ytoggle

        a[n] = '}';n++//end last else of else if
  
    a[n] = '}';n++//end if for oval
    
    /////////////////////////////////////////////////////    

    a[n] = 'if(!oval){';n++//for testing
    
    if(dvar.useSeed.value){a[n] = 'randNum = rand();';n++}
    else{a[n] = 'randNum = Math.random();';n++}      
    
    a[n] = 'switch (whatEdge){';n++//for testing
    
    a[n] = 'case 0:  // top edge';n++
    a[n] = 'x = randNum*(outputSize.x + mV.maxPattern) - mV.maxPattern/2';n++ 
    if(dvar.useSeed.value){a[n] = 'randNum = rand();';n++}
    else{a[n] = 'randNum = Math.random();';n++}       
    a[n] = 'y= (outputSize.y/2 - mV.yAx)* randNum';n++   
    a[n] = 'break;';n++
 
    a[n] = 'case 1:  // bottom edge';n++      
    a[n] = 'x = randNum*(outputSize.x + mV.maxPattern) -  mV.maxPattern/2';n++ 
    if(dvar.useSeed.value){a[n] = 'randNum = rand();';n++}
    else{a[n] = 'randNum = Math.random();';n++}       
    a[n] = 'y= (outputSize.y/2 - mV.yAx)* randNum +mV.boxY + outputSize.y/2 - mV.yAx';n++   
    a[n] = 'break;';n++

    a[n] = 'case 2:  // left edge';n++    
    a[n] = 'y = randNum*(outputSize.y + mV.maxPattern) - mV.maxPattern/2';n++ 
    if(dvar.useSeed.value){a[n] = 'randNum = rand();';n++}
    else{a[n] = 'randNum = Math.random();';n++}       
    a[n] = 'x= (outputSize.x/2 - mV.xAx)* randNum';n++    
    a[n] = 'break;';n++

    a[n] = 'case 3:  // right edge';n++
    a[n] = 'y = randNum*(outputSize.y + mV.maxPattern) -  mV.maxPattern/2';n++ 
    if(dvar.useSeed.value){a[n] = 'randNum = rand();';n++}
    else{a[n] = 'randNum = Math.random();';n++}   
    a[n] = 'x= (outputSize.x/2 - mV.xAx)* randNum +mV.boxX + outputSize.x/2 - mV.xAx';n++  
    a[n] = 'break;';n++    
    a[n] = '}';n++//end switch
    a[n] = '}';n++//end if for square
///////////////////////////////////////////////////////////////////


    
    a[n] = 'xA = x-outputSize.x/2;';n++
    a[n] = 'yA = (y-outputSize.y/2)*-1;';n++
 
    //////////////////////////////////////////////////////////////
        
    a[n] = 'RenderAPI.translate(x, y)';n++
    a[n] = 'RenderAPI.scale(localScale, localScale)';n++
    
    a[n] = 'switch(rotateMethod){';n++
        a[n] = 'case 0:';n++
            a[n] = 'var rotate = 360/30 * Math.floor(rand() * 30) // 30 distinct rotations';n++
            a[n] = 'break;';n++
        a[n] = 'case 1:';n++
            a[n] = 'var rotate = 0';n++
            a[n] = 'break;';n++  
        a[n] = 'case 2:';n++
            a[n] = 'var rotate = ' + dvar.randBrdCusAng.text;n++
            a[n] = 'break;';n++
    a[n] = '}';n++//end switch
    
    if(dvar.randBrdAngJit.value){a[n] = 'rotate += Math.random()*8-16';n++}   
    
    if(parseInt(dvar.randBrdRotateDbx.selection)==3){rotateLines ()}
    else{a[n] = 'RenderAPI.rotate(rotate)';n++}
      
    /////////////////////////////////////////////////////////////////
    
    a[n] = 'if(oval){';n++
    
        a[n] = 'baseA =  Math.floor ((Math.atan (xA/yA))*(180/Math.PI )) + rotate';n++
        a[n] = 'if(yA<0){baseA += 180}';n++
        
        a[n] = 'RenderAPI.rotate (baseA)}';n++
    a[n] = 'else{RenderAPI.rotate (angle + rotate)}';n++
      
    colorLines()
    
    
    a[n] = 'pattern.render(RenderAPI)';n++
    a[n] = 'RenderAPI.popMatrix()';n++
   
    a[n] = '}';n++
   


    return a
    colorLines()
    
};//end function random border

function enableUI(){
    
    dlg.tabPn.scriptTab.text = dvar.scriptDbx.selection.text + ' Settings';
    dlg.tabPn.passTab.enabled = dlg.tabPn.refTab.enabled = true;
    if(dvar.useRefFile.value){dvar.assignColor.enabled = dlg.tabPn.refTab.fillRangeGp.enabled = dvar.refSize.enabled = dvar.refRotate.enabled = true}
    else{dvar.assignColor.value = dvar.assignColor.enabled = dlg.tabPn.refTab.fillRangeGp.enabled = dvar.refSize.value = dvar.refSize.enabled = dvar.refRotate.value = dvar.refRotate.enabled = false};
    
    if(dvar.fillRange.value){dvar.fillMinStxt.enabled = dvar.fillMin.enabled = dvar.fillMaxStxt.enabled = dvar.fillMax.enabled = true}
    else{dvar.fillMinStxt.enabled = dvar.fillMin.enabled = dvar.fillMaxStxt.enabled = dvar.fillMax.enabled = false}


    brickGp.visible = crossGp.visible = sprialGp.visible = randGp.visible = randBrdGp.visible = symGp.visible = false

            switch(parseInt (dvar.scriptDbx.selection)){
                case 0://brick
                    brickGp.visible = true;
                    dvar.angleJitCbx.value ? brickGp.angleJitGp.enabled = true : brickGp.angleJitGp.enabled = false;
                break;
                
                case 1://weave
                    crossGp.visible = true;
                break;  
                
                case 2://spiral
                    sprialGp.visible = true;
                    dlg.tabPn.refTab.enabled = false;
                    dvar.useRefFile.value = dvar.assignColor.value = dvar.assignColor.enabled = dvar.refSize.value = dvar.refSize.enabled = dvar.refRotate.value = dvar.refRotate.enabled = false;                   
                break;  
                
                case 3://random
                      randGp.visible = true;   
                      dvar.refSize.enabled = false
                    if(dvar.randUseDens.value){
                        randDensMin = .1;
                        randDensMax = 15;
                        randFloat = 'float';
                        randGp.densGp.dStxt.text = 'Density (.1~15)'}
                    else{
                        randDensMin = 1;
                        randDensMax = 100000; 
                        randFloat = 'int';
                        randGp.densGp.dStxt.text = 'Number (1~100,000)'};
                     dvar.randDens.notify()                      
                break;   
                
                case 4://random border
                    randBrdGp.visible = true; 
                    dvar.refSize.enabled = false;
                    if(dvar.randBrdUseDens.value){
                        randBrdDensMin = .1;
                        randBrdDensMax = 15;
                        randBrdFloat = 'float';
                        randBrdGp.densGp.dStxt.text = 'Density (.1~15)';}
                    else{
                        randBrdDensMin = 1;
                        randBrdDensMax = 100000;
                        randBrdFloat = 'int';
                        randBrdGp.densGp.dStxt.text = 'Number (1~100,000)';}
                    
                    dvar.randBrdDens.notify();
                break;
                
                case 5://symmetry
                    symGp.visible = true;
                    dlg.tabPn.passTab.enabled = dvar.addLayer.value = false;
                    dvar.pass.text = 1
                    dlg.tabPn.refTab.enabled = false;
                    dvar.useRefFile.value = false;                       
                break;                  
    
                };//end switch  
            
         if(dvar.useRefFile.value){
            dvar.assignColor.enabled = true
            if(parseInt (dvar.scriptDbx.selection)<2){dvar.refSize.enabled = true}
            else{dvar.refSize.enabled = false}
            }
        else{dvar.assignColor.value = dvar.assignColor.enabled = dvar.refSize.value = dvar.refSize.enabled = dvar.refRotate.value = dvar.refRotate.enabled = false};
            
     if(!dvar.useRefFile.value){dvar.assignColor.value = dvar.assignColor.enabled = dvar.refSize.value = dvar.refSize.enabled = dvar.refRotate.value = dvar.refRotate.enabled = false}       
    dvar.assignColor.value ? dlg.tabPn.refTab.colorLevelGp.enabled = true : dlg.tabPn.refTab.colorLevelGp.enabled = false;

     
     if(dvar.refSize.value){dlg.tabPn.refTab.sizeGp.enabled = true}
     else{dlg.tabPn.refTab.sizeGp.enabled = false};
     
    //if reference file is used and pattern rotate is selected, this turns on and off some of the selections in the dropdown list for the random script and random border script method of rotating.
    //Makes sure the dropbox selection is not null.
     if(dvar.refRotate.value){dlg.tabPn.refTab.rotateGp.enabled = dvar.randRotateDbx.items[3].enabled = true}
     else{
         dlg.tabPn.refTab.rotateGp.enabled = dvar.limitRotation.value = dvar.randRotateDbx.items[3].enabled = false;
         if(!dvar.randRotateDbx.selection){dvar.randRotateDbx.selection = 0}
         if(!dvar.randBrdRotateDbx.selection){dvar.randBrdRotateDbx.selection = 0}
         };

    if(dvar.limitRotation.value){dvar.limitRotationEtxt.enabled = true}
    else{dvar.limitRotationEtxt.enabled = false};
    
    update = true;
    };//end function enable UI
