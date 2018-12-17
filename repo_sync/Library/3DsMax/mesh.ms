mesh vertices:#([0,0,0],[40,0,0],[40,25,0],[0,25,0]) faces:#([3,2,1], [1,4,3])
extrudeFace $ #(1) (80 * 0.5) 40 dir:#common
extrudeFace $ 2 (80 * 0.5) 40
extrudeFace $ #(1,2) (80 * 0.5) 50 dir:#common