---------------------------------------------------------------------------
--                        Math Object Plugin Script                      --
--                                                                       --
--                      Alexander Esppeschit Bicalho                     --
-- 	                    Kinetix Training Specialist                      --
--                         abicalho@brasilmail.com                       --
--                    http://www.ktx.com/learning_center                 --
---------------------------------------------------------------------------


plugin simpleObject MathObj
    name:"Math Object"
    classID:#(145465,542123)
	category:"Scripted Objects"
(


    parameters main rollout:params
    (
        width type:#float ui:width default:0
        depth type:#float ui:depth default:0
		max_height type:#float ui:height default:10e10
		use_limits type:#boolean ui:use default:false
		x_start type:#float ui:x_start default:(-10)
		y_start type:#float ui:y_start default:(-10)
		x_end type:#float ui:x_end default:(10)
		y_end type:#float ui:y_end default:(10)
		resolution type:#integer ui:resolution default:20
		formula type:#string animated:false default:"cos(X^2-Y^2)"
   )
    
    rollout params "Math Object Parameters"
    (
		group "Size"
		(
        spinner width "Width" type:#worldunits range:[-1000,1000,0] align:#right
        spinner depth "Depth" type:#worldunits range:[-1000,1000,0] align:#right
		spinner height "Max Height" type:#float range:[0,10e15,10e10] align:#right
		)
		group "Math Parameters"
		(
		checkbox use "Use Limits" checked:false
		label xx "Start" align:#left
		spinner x_start "X " range:[-1000,1000,-10] align:#left fieldwidth:43
		spinner y_start "Y " range:[-1000,1000,-10] align:#left fieldwidth:43
		label yy "End" pos: [85,134] align:#left
		spinner x_end "X " range:[-1000,1000,10] align:#right fieldwidth:43
		spinner y_end "Y " range:[-1000,1000,10] align:#right fieldwidth:43
		spinner resolution "Resolution" type:#integer range:[4,100,4]
		edittext form "Formula" text:"cos(X^2-Y^2)"
		button upd "Update Formula" width:120
		)
		label abt01 "Math Object Plugin Script"
		label abt03 "Alexander Esppeschit Bicalho"
		label abt05 "Kinetix Training Specialist"
		label abt04 "http://www.origamy.com.br"
	
	on upd pressed do
		(
		formula = form.text
		width.value = width.value + 0
		)
	
	on use changed state do
		(
		if use.checked then
			(
			x_start.enabled = true
			y_start.enabled = true
			x_end.enabled = true
			y_end.enabled = true
			)
			else
			(
			x_start.enabled = false
			y_start.enabled = false
			x_end.enabled = false
			y_end.enabled = false
			)
		)

	on params open do
		(
		if use.checked then
			(
			x_start.enabled = true
			y_start.enabled = true
			x_end.enabled = true
			y_end.enabled = true
			)
			else
			(
			x_start.enabled = false
			y_start.enabled = false
			x_end.enabled = false
			y_end.enabled = false
			)
		form.text = formula
		)

	
    )
    
    on buildMesh do
    (
		v = #()
		s = 1
		local x,y,z
		fn convert_formula formula xx yy =
			(
			new_formula = ""
			for i in 1 to formula.count do
				(
				actual = substring formula i 1
				case actual of
					(
					"X" : new_formula += ("(" + xx as string + ")")
					"Y" : new_formula += ("(" + yy as string + ")")
					default: new_formula += actual
					)
				)
			new_formula
			)
		for i in 0 to resolution do
			for j in 0 to resolution do
				(
				if use_limits then
					(
					xf = i*width/resolution
					yf = j*depth/resolution
					x_range = x_end - x_start
					y_range = y_end - y_start
					x = (i*x_range/resolution)+x_start
					y = (j*y_range/resolution)+y_start
					)
					else
					(
					xf = i*width/resolution
					yf = j*depth/resolution
					x = xf
					y = yf
					)
				zf = convert_formula formula x y
				z = execute (zf as string)
				if z > max_height then z = max_height
				if z < (-max_height) then z = (-max_height)
				v[s] = [xf,yf,z]
				s += 1
				)
		f = #()
		s = 1
		for i in 1 to resolution do
			for j in 0 to (resolution-1) do
				(
				f[s] = [i+(j+1)+(resolution*(j+1)),i+j+(resolution*j),i+j+(resolution*j)+1]
				f[s+1] = [i+j+(resolution*j)+1,i+(j+1)+(resolution*(j+1))+1,i+(j+1)+(resolution*(j+1))]
				s += 2
				)
		setMesh mesh verts:v \
                     faces:f
    )
    
    tool create
    (
        on mousePoint click do
            case click of 
            (
                1: nodeTM.translation = gridPoint
                2: #stop
            )        
        on mouseMove click do 
            case click of 
            (
                2: (width = gridDist.x; depth = gridDist.y)
            )        
    )
)
