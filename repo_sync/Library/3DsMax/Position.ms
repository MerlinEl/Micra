point pos:selection.center

$.pos.x = 0
$.pos.y = 0
$.pos.z = 0

$foo.pos.x += 23 -- move the node 23 units in x
$baz.rotation.angle *= 2 -- double the rotation
p = $foo.pos -- get foo’s position as a ‘detached’ point3
p.x += 23 -- set the x prop of that point, it doesn’t know
-- about foo anymore, foo’s pos is not changed
$foo.pos = p -- set foo’s new position