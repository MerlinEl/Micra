// You can modify the code below but keep in mind that as with any scripting
// you can break things. Keep a backup copy.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// get the size of the output area
var outputSize = RenderAPI.getParameter(kpsSize)
// get the location of the top left corner of the bounding rectangle around the selected area
var outputOrigin = RenderAPI.getParameter(kpsOrigin)


///////////////////////////////////////////////////////////////////////////

var pattern = RenderAPI.getParameter(kpsPattern)

var patternSize = pattern.getParameter(kpsSize)


var sizex = Math.floor((outputSize.x + patternSize.x-1) / patternSize.x) +  2 // 2 is for border
var sizey = Math.floor((outputSize.y + patternSize.y-1) / patternSize.y) +  2

var occupied = new Array(sizex*sizey)
for (var i = 0; i < sizex*sizey; i++)
    occupied[i] = false;
 // set borders
 for (var x= 0; x < sizex; x++)
 {
     occupied[x] = true;
     occupied[x + (sizey-1)*sizex] = true;
}
 for (var y= 0; y < sizey; y++)
 {
     occupied[0 + y*sizex] = true;
     occupied[sizex-1 + y*sizex] = true;
}
 

function positionOccupied (frame)
{
    var x = Math.floor((frame.position().x + patternSize.x) / patternSize.x)
    var y = Math.floor((frame.position().y + patternSize.y) / patternSize.y)

    return occupied[x + sizex * y ]
}

function markOccupied (frame)
{
     var x = Math.floor((frame.position().x + patternSize.x) / patternSize.x)
     var y = Math.floor((frame.position().y + patternSize.y) / patternSize.y)

    occupied[x + sizex * y ] = true
}

/////////////////////////////////////////////////////////////////////////////////////
function ModuleSeek(frame, delay) 
{
    this.frame = frame
    this.delay = delay
    markOccupied (frame)
}


 ModuleSeek.prototype.produce = function (engine) 
 {
     if (this.delay > 0)
     {
         this.delay--;
         return kCallAgain;
     }
    // test if we can move forward
    this.frame.advance(patternSize.x)
    if (positionOccupied (this.frame))
    {
        // try to turn right
        //Engine.message ("position occupied at ", this.frame.position().x, ", ", this.frame.position().y)
        
        this.frame.advance(-patternSize.x) // move back
        this.frame.rotateDeg(-90);
        this.frame.advance(patternSize.x);
        if (positionOccupied(this.frame))
        {
            Engine.removeModule(this)
            //Engine.message ("done")
            return kDontCallAgain
        }
    }
    markOccupied (this.frame)
    return kCallAgain
}

ModuleSeek.prototype.render = function (api) 
{
    api.pushMatrix()       
    api.rotate(180)
    pattern.render(api)
    api.popMatrix()

    return kCallAgain
}



var frame = new Frame2();
//frame.setSize (patternSize.x, patternSize.x)
frame.rotateDeg(90)
frame.setPosition (patternSize.x/2, patternSize.y/2)

Engine.addModule (new ModuleSeek (frame, 0 /* delay */))


if (0)
{
    // second one
    var frame2 = new Frame2();
    //frame.setSize (patternSize.x, patternSize.x)
    frame2.rotateDeg(90)
    frame2.setPosition (patternSize.x*0.5, patternSize.y*1.5)

    Engine.addModule (new ModuleSeek (frame2, 1 /* delay */))
}

// Setting the bounding box like this will insure that neighboring fills are aligned
Engine.setSceneBBox (0,  outputSize.x,  0,  outputSize.y)

Engine.setParameter (kRunSimulation, 1)
Engine.setParameter (kNumSimulationSteps, 2000)
