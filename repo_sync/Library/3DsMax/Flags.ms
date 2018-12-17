0000000F

00000001

flag_25 = bit.shift 1 25
f_sel = polyOp.getFaceSelection $
polyOp.setFaceFlags $ f_sel flag_26 mask:flag_26
polyOp.getFaceFlags $ (f_sel as array)[1]
faces_flag_25 = polyOp.getFacesByFlag $ flag_25
polyOp.setFaceSelection $ faces_flag_25






fa = (polyOp.getFacesByFlag obj 8 ) --faces bakwards from viewport



polyOp.getFaceFlags <Poly poly> <int face>
polyOp.setFaceFlags <Poly poly> <facelist> <int flag> mask:<int=0> undoable:<boolean=false>
polyOp.getFacesByFlag <Poly poly> <int flag> mask:<int maskflag>
bit 25-32: available for general use


polyOp.getFaceFlags $ 170
polyOp.setFaceSelection $ (polyOp.getFacesByFlag $ 8 mask:1)
fsel = polyOp.getFaceSelection $
polyOp.getFaceFlags $ 440
polyOp.setFaceFlags $ fsel 8 mask:1 undoable:false

polyOp.getFacesByFlag $ 4 mask:1





