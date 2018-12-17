hGrid = grid name:"Grid_Helper" ()     --create Grid_Helper
rotate hGrid (angleaxis 90 [0,1,0])    --rotate Grid_Helper vertical
activeGrid = hGrid                   --activate Grid_Helper
$.alignToGrid #Vertex                --align vertex Grid_Helper
delete hGrid                         --delete Grid_Helper