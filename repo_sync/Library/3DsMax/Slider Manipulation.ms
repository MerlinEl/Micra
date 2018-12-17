-- This manipulator creates a slider helper object that manipulates
-- itself.  

-- Written by Scott Morrison, July 25, 2000
-- Based on Peter Watje's 2d slider object

-- The slider uses a param block to store the slider value.  
-- This can be used in conjunction with parameter wiring to control
-- other objects in the scene.

plugin simpleManipulator sliderManipulator
    name:"Slider"
    classID:#(0x47db14ef, 0x4e9b5990)
    category:"Manipulators"
(
    -- Set the yellow and red colors for the gizmo
    local greenColor =  colorMan.getColor #manipulatorsActive
    local redColor =    colorMan.getColor #manipulatorsSelected
    local yellowColor = colorMan.getColor #manipulatorsInactive

    -- sliderOffset is the distance in pixels from the "+" to the slider bar
    local sliderOffset = 9

    -- textYOffset is the vertical distance from the slider to the text
    local textYOffset = 10

    -- textXOffset is the horizantal distance from the slider to the text
    local textXOffset = -5

    -- The minimum width a slider can have in pixels
    local minWidth = 10


    parameters main rollout:paramRollout
    ( 
         -- The value of the slider
         value      type:#float   animatable:true  ui:spnValue  default: 0.0
		 on value set val do
		 (
			-- Adjust the min and max accordingly
         	if ((val < this.minVal)) then this.minVal = val
			if ((val > this.maxVal)) then this.maxVal = val
	   	 )

         -- The min and max values for the slider
         minVal     type:#float   animatable:true  ui:spnMin    default: 0.0
         maxVal     type:#float   animatable:true  ui:spnMax    default: 100.0
 		 on minVal set val do
		 (
         	if ((val > this.maxVal)) then this.minVal = this.maxVal
			if (this.value < val) then this.value = val
		 )
		 on maxVal set val do
         (
		 	if ((val < this.minVal)) then this.maxVal = this.minVal
			if (this.value > val) then this.value = val
		 )

         -- The slider position as a percentage of screen space
         xPos       type:#float   animatable:false ui:spnXPos   default: 0.0
         yPos       type:#float   animatable:false ui:spnYPos   default: 0.0

         -- The width of the slider in pixels
         width      type:#float   animatable:false ui:spnWidth  default: 100.0

         -- When the hide flag is true, the slider bar and value are not draw
         hide       type:#boolean animatable:false ui:checkHide default: false

         -- The display name of the slider
         sldName   type:#string  animatable:false ui:labelEdit default: ""

        -- Snap toggle
         snapToggle type:#boolean animatable:false ui:checkSnap default: true

         -- snap value
         snapVal    type:#float   animatable:false  ui:spnSnapVal default: 0.01
    )

    -- The rollout for the slider parameters
    rollout paramRollout "Parameters"
    (
        Edittext labelEdit   "Label:"        text:""

        Spinner  spnValue   "Value:"       range:[-1.0e30, 1.0e30, 0.0] 
        Spinner  spnMin     "Minimum:"     range:[-1.0e30, 1.0e30, 0.0] 
        Spinner  spnMax     "Maximum:"     range:[-1.0e30, 1.0e30, 100.0] 
        Spinner  spnXPos    "X Position:"  range:[0.0, 1.0, 0.0] scale:0.01
        Spinner  spnYPos    "Y Position:"  range:[0.0, 1.0, 0.0] scale:0.01
        Spinner  spnWidth   "Width:"       range:[10.0, 1000.0, 100.0] 

        Checkbox checkSnap  "Snap:"        checked:false
        Spinner  spnSnapVal "Snap Value:"  range:[0.0, 10000.0, 0.1]

        Checkbox checkHide  "Hide:"        checked:false

    )

    -- This manipualtor manipulates itself
    on canManipulate target  return (classOf target) == sliderManipulator

    -- Creation mouse procedure
    tool create
    (
        on mousePoint click do
           case click of
           (
              1: 
              (
                -- Compute the percentage of of the mouse point in screen space
                this.xPos = viewPoint.x / gw.getWinSizeX()
                this.yPos = viewPoint.y / gw.getWinSizeY()

                #stop 
              )
           )

    )

    -- Create the manipulator gizmos.
    on updateGizmos do
    (
        -- Clear the current gizmo cache
        this.clearGizmos()

        -- If this is not a stand-alone manip, get values from the manip target
        
        local lsldName = this.sldName
        
        if (target != undefined) then 
        (
           this.value      = target.value
           this.minVal     = target.minVal
           this.maxVal     = target.maxVal
           this.xPos       = target.xPos
           this.yPos       = target.yPos
           this.width      = target.width
           this.hide       = target.hide
           this.snapToggle = target.snapToggle
           this.snapVal    = target.snapVal
           lsldName        = target.sldName
           unselColor  = greenColor
        ) 
        else
        (
           unselColor  = yellowColor
        )


        -- Compute the origin of the slider in screen space
        local x = xPos * gw.getWinSizeX()
        local y = yPos * gw.getWinSizeY()

        -- These flags are used for all the gizmos
        local flags = (gizmoUseScreenSpace + gizmoActiveViewportOnly)

        -- Gizmo 0
        -- This is the box that you use the move the slider
        local pos = [x, y, 0.0]
        this.addGizmoMarker #hollowBox pos flags unselColor redColor

        -- Gizmo 1
        -- This is the plus-sign used to toggle the hide flag
        pos =  [x + sliderOffset, y, 0.0]
        this.addGizmoMarker #plusSign pos flags unselColor redColor

        -- Compute the text label
        local str
        local relVal = value
		-- always draw the slider value within the min and max bounds
		if relVal < minVal do relVal = minVal
		if relVal > maxVal do relVal = maxVal

        if (hide) then str = lsldName
        else 
        (
			if lsldName.count > 0 then str = lsldName + ": " + (relVal as string)
            else str = relVal as string
        )

        local textLoc = [x + textXOffset, y - textYOffset, 0.0f]

        -- Gizmo 2
        -- The text with the name and value
        this.addGizmoText str textLoc flags unselColor redColor

        -- If the slider is hidden, don't draw any more
        if hide then return ""

        -- Draw the slider bar
        local barStart = x + 2 * sliderOffset
        local barPos = [barStart, y, 0.0]
        local barEnd = [barStart + this.width, y, 0.0]
 
        -- Create a polyline gizmo
        local giz = manip.makeGizmoShape()
        giz.AddPoint barPos
        giz.AddPoint barEnd
 
        -- Gizmo 3
        -- The slider bar
        this.addGizmoShape giz flags unselColor unselColor
        
        -- Draw the slider "thumb" gizmo
		relVal = (relVal - minVal) / (maxVal - minVal)
        local valPos = [barStart + relVal * width, y + 10, 0.0f]

        -- Gizmo 4
        -- The slider thumb triangle
        this.addGizmoMarker #triangle valPos flags unselColor redColor

        local resizePos = [barStart + width + sliderOffset, y, 0.0f]
        
        -- Gizmo 5
        -- The slider resize diamond
        this.addGizmoMarker #diamond resizePos flags unselColor redColor

        -- return an empty string so no tool tip is displayed
        return ""
    )

    -- mouseMove is called on every mouse move when dragging the manip
    -- It needs to convert the mouse position 'm' into a new value for the slider
    on mouseMove m which do
    (
        local xSize = gw.getWinSizeX()
        local ySize = gw.getWinSizeY()

        if (which == 0)  then 
        (
            -- Gizmo 0

            -- Set the slider postition
            target.xPos = m.x / xSize
            target.yPos = m.y / ySize
        ) 
        else if (which == 4) then 
        (
            -- Gizmo 4

            -- Set the slider value
            local x = xPos * xSize
            local barStart = x + 2.0 * (sliderOffset as float)
            local newVal = ((m.x as float) - barStart) / width
			newVal = minVal + newVal * (maxVal - minVal)
		
            -- Clamp the value
            if (newVal < minVal) then newVal = minVal
            if (newVal > maxVal) then newVal = maxVal

            -- Snap, if needed
            if (snapToggle) then 
				if (snapVal != 0) then newVal = newVal - (mod newVal snapVal)

            -- Set the value in the target
            target.value = newVal
        ) 
        else if (which == 5) then 
        (
           -- Gizmo 4

            -- Set the slider width
            local x = xPos * xSize
            local barStart = x + 2.0 * sliderOffset
            local newWidth = m.x - sliderOffset - barStart

            -- Clamp the width
            if (newWidth < minWidth) then newWidth = 10.0

            -- Set the width in the target
            target.width = newWidth
        )
    )

    on mouseDown m which do
    (
      -- Toggle the value of the "Hide" state
      if (which == 1) then target.hide = not hide 
    )
)
