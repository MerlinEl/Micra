RadialMenu
----------
--https://www.itnetwork.cz/javascript/oop/javascript-tvorba-kulateho-menu-dokonceni
-----------

fn generateRadialButtons btn_cnt circ_radius = (

	local positions = mcMath.rotatePointAroundCenter [0,0,0] [0,0,1] circ_radius steps:btn_cnt
    for p in positions do (
	
        local btn = box()
        local degress_step = 360 / btn_cnt
		btn.pos = p
	)
)


generateRadialButtons 8 100 


/*
fn deg2rad degress = (

    return PI / 180 * degress
)


fn generateRadialButtons btn_cnt btn_size circ_radius = (

    for i = 1 to btn_cnt do (
	
        local btn = box()
        local degress_step = 360 / btn_cnt

        local degress = (degress_step * i);

        local s = sin (deg2rad degress)
        local c = cos (deg2rad degress)
        local x = circ_radius / 2 + (c * circ_radius / 2) - btn_size / 2;
        local y = circ_radius / 2 + (s * circ_radius / 2) - btn_size / 2;


        btn.pos.x = y --top button corner
        btn.pos.y = x --left button corner
	)
)


generateRadialButtons 8 5 1000 

rotatePointAroundCenter center dir radius steps:8 inverse:false debug:false clr:green*/