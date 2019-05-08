--MatrixPp
--该插件继承于simpleObject对象--将场景中的一个模型解析至新节点物体的参数变量中，模型信息的参数变量如下

--vertArybuff:是一个Point3的数组,当拾取一个模型的时候，模型所有三角面加入一个容器，从模型任意一个三角面开始，
--        寻找该三角面所在的poly多边形面，将多边形面所引用的点坐标加入vertArybuff，同时处理完成后，将
--        该poly下包含的所有三角面从上面的三角面容器中删除(否则死循环！！！)，删除后的新三角面容器中，再随机抽取
--        一个三角面(这里是直接取数组第一个)开始即可循环上面动作，直至三角面容器的数量为0，即全部遍历完

--faceArybuff:是一个Point3Tab 当从上一步计算完一个poly面所包含的顶点后，由于顶点序列重新加入vertArybuff数据区中，故三角面的索引也
--        发生变化，该参数变量将保存通过算法校正后的新的面顶点索引，一个poly内所有三角面的新索引依次加入该参数区

--faceVFI:intTab型,该数组是根据vertArybuff数组中，某一个poly面所引用的顶点是从第几个到第几个。在vertArybuff顶点算法中，所加入的
--        顶点都是根据poly面所引用的顶点依次加入的。faceVFI的第一个数字为0，下一个数字为第一个poly面所引用到的顶点序列编号，
--        再下一个为第二个poly面引用到的顶点序列编号，以此类推。例如，模型的第一个poly由四个顶点构成，则faceVFI中第二个数字
--        为4，表示第一个poly面的顶点索引区为（0-4]之间(不包括0，包括4)，如果第二个poly面由5个顶点组成，当5个顶点加入
--        vertArybuff后，总数为9，则faceVFI的第三个数字为9，表示第二个poly面的索引段为从上一个索引段到9，即(4,9](5，6，7，8，9) 
--        5个顶点构成，以此下去。faceVFI的总大小为 poly总面数+1  

--faceMTbuff:matrix3Tab型，该矩阵数组保存所有poly面的矩阵，该矩阵由一个poly面下的所有顶点的平均法线为z轴，所有顶点位置的中心为平移轴
--        所构建,faceMTbuff为整个程序运行时的遍历引用对象，因为有多少个poly面就有多少个矩阵  

--upd_faceMTbuff:matrix3Tab类型，该矩阵数组所保存poly面在每一次更新后的最新的矩阵，在节点外部可以引用该节点的该参数访问更新后的面的矩阵信息

plugin simpleObject MatrixPp_Edit
    name:"MatrixPp_Edit"
    classID:#(0x5c3c4a22, 0x17edf3b5)
    version:1.0
    category:"Matrix_Center_v3"
(
    --设置可见边的相关变量，本版本暂时不使用，只记录
    local setVIS = false
    local visEDG
    
    --更新完位置后保存面的在模型局部坐标系下的矩阵( 转换为世界坐标系矩阵需与模型矩阵相乘 )
    local upd_faceMTbuff = #()
    
    parameters main rollout:params
    (
        
        --该变量用于单次更新，即在update中检测到为true时，执行相关更新，更新后将该变量设置为false
        once_update type:#boolean animatable:false default:false
        
        --该变量记录拾取节点的激活的UV通道数量
        nummaps type:#integer animatable:false default:1
        
        --引用的矩阵，设计为自身的矩阵，但是本身不能引用本身，可用其他物体绑定该物体，再将其他物体的矩阵转移进来
        mt_node type:#node animateable:true
        
        --影响位置信息
        fpos type:#point3 animateable:true default:[0,0,0]
        
        TimeVal type:#float animateable:true default:0 ui:TimeVal    
        
        --用于与Float_script中的F时间参数绑定，以达到渲染更新的目的,暂时不用
        dpd type:#integer animateable:true default:1
        
        --顶点数据
        vertArybuff type:#point3Tab tabSize:1 tabSizevariable:true default:[0,0,0]
        
        --三角面数据
        faceArybuff type:#point3Tab tabsize:1 tabSizevariable:true default:[1,1,1]
        
        --一个POLY面所引用的顶点集合地址段点集合
        faceVFI type:#intTab tabsize:1 tabSizevariable:true default:0
        
        --Poly面所在的矩阵,按poly面的序号顺序,矩阵的z轴为面平均法线
        faceMTbuff type:#matrix3Tab tabsize:0 tabSizevariable:true
    
        --三轴旋转角度
        sp_rot_x type:#float animateable:true default:0 ui:sp_rot_x 
        sp_rot_y type:#float animateable:true default:0 ui:sp_rot_y
        sp_rot_z type:#float animateable:true default:0 ui:sp_rot_z
        
        --旋转引用半径
        radius type:#float animateable:true default:1 ui:radius
        randradiu type:#float animateable:true default:0 ui:randradiu
        
        --距离检测随机浮动数值
        randVal type:#float animateable:true default:0 ui:randVal
        
        txtchk type:#boolean default:false ui:chk1
        sc_txt type:#string default:"" ui:edt1
        
    )
    

    fn filterObject obj = ( try( (classof obj.mesh == triMesh) and (getnumverts obj.mesh) > 0 and (getnumfaces obj.mesh) > 0 )catch( false ) )
    
    rollout params "MTC parameters" width:250 height:765
    (
        pickbutton pk "Pick Shape" pos:[20,14] width:116 height:24  toolTip:"#center" filter:filterObject
        GroupBox grp1 "Params" pos:[8,46] width:147 height:288
        spinner timeVal "TimeVal" pos:[25,75] width:121 height:16 range:[0,999999,0] type:#float scale:0.1
        GroupBox grp6 "Rotate_Axis_Angles:" pos:[17,136] width:128 height:185
        spinner sp_rot_x "x" pos:[56,222] width:74 height:16 range:[-9999,9999,0]
        spinner sp_rot_y "y" pos:[56,255] width:74 height:16 range:[-9999,9999,0]
        spinner sp_rot_z "z" pos:[56,287] width:74 height:16 range:[-9999,9999,0]
        spinner radius "radius" pos:[39,164] width:91 height:16 range:[-9999,9999,1]
        spinner randradiu "random" pos:[39,188] width:91 height:16 range:[0,99999,0]
        spinner randVal "randVal" pos:[25,101] width:121 height:16 range:[0,999999,0] type:#float scale:0.1
        edittext edt1 "" pos:[4,395] width:149 height:118
        checkbox chk1 "active" pos:[98,522] width:54 height:21
        GroupBox grp5 "Edit_Matrix" pos:[3,369] width:156 height:286
        
        
        on params open  do
        (
            edt1.enabled = not chk1.checked
        )
        
        on chk1 changed state do
        (
            edt1.enabled = not state
        )
        
        on pk picked obj do
        (
            with redraw off
            (
                if obj != undefined do
                (
                    --**************释放内部变量之前的数据*************
                    free faceMTbuff
                    free faceVFI
                    free faceArybuff
                    free vertArybuff
                    free upd_faceMTbuff
                    faceMTbuff = #()
                    faceVFI=#(0)
                    faceArybuff=#()
                    vertArybuff=#()
                    upd_faceMTbuff = #()
                    --***************************************
                    
                    pk.text = obj.name
                    nummaps = meshop.getnumMaps obj.mesh  --取得目标物体的纹理通道数量
                    once_update = true  --打开更新
                    
                    ------------------ 以多边形的模型的面解析模型 -------------------
                    local vertbuff = #()     --储存新模型的顶点数组
                    local facebuff = #()    --储存新模型的面索引数组
                    local visEdge = #()        --储存新模型的可见边情况

                    local themesh = snapshotasmesh obj    --获得原始模型的快照
                    local objimt = inverse obj.transform  --取得逆矩阵
                    
                    local numfaces = meshop.getnumfaces themesh  --取得模型三角面数
                    local facebitary = #{1..numfaces}   --将面数索引号转换为bitarry
                    local findex = 1  --用于接下来遍历三角面的索引
                    
                    while facebitary.numberset > 0 do   --如果三角面索引bitarray还存在未遍历的索引编号，则处理该面
                    (
                        local polybay = meshop.getpolysUsingface themesh findex  --根据一个三角面取得与其在同一个多边形面下的所有三角面集合
                        local val_count = vertbuff.count  --取得之前顶点数量，新的顶点编号才能往后叠加
                        local usevert = (meshop.getVertsUsingFace themesh polybay) as array  --根据三角面集合返回所有三角面所引用的顶点bitarray
                        
                        --获得所有顶点法线和
                        local all_nor = [0,0,0]
                        --临时所有顶点坐标和
                        local all_pt = [0,0,0]
                        
                        --将取得后的顶点加入顶点储存里面
                        for i in usevert do
                        (
                            local pt = (meshop.getvert themesh i)*objimt
                            append vertbuff pt
                            all_nor += (getNormal themesh i)
                            all_pt += pt
                        )
                        
                        --**********根据发法线，和所有顶点的平均位置，生成矩阵**********
                        all_pt /= usevert.count
                        all_nor /= usevert.count
                        all_nor = normalize all_nor
                        
                        --直接根据函数生成矩阵法
                        --local tpmt = matrixFromNormal all_nor
                        
                        local tpmt = matrix3 1
                        --自行根据坐标系z轴计算
                        --防止两向量重合
                        if all_nor == [0,0,1] or all_nor == [0,0,-1] do
                        (
                            all_nor = normalize (all_nor + [0.00001,0,0] + (normalize [all_pt.x,all_pt.y,0])*0.00002)
                        )
                        
                        local temp_x = normalize (cross [0,0,1] all_nor)
                        local temp_y = normalize (cross all_nor temp_x)
                        tpmt.row1 = temp_x
                        tpmt.row2 = temp_y
                        tpmt.row3 = all_nor
                        tpmt.row4 = all_pt
                        
                        append faceMTbuff tpmt  --添加矩阵到poly矩阵列表
                        
                        --初始化更新后面矩阵
                        append upd_faceMTbuff tpmt --将首次的矩阵当做初始化值更新到完毕后矩阵集合里
                        
                        --**************************************************************
                        
                        append faceVFI vertbuff.count  --将最新的顶点数量加入faceFVI分段集合
                        
                        --遍历每个poly集合内
                        for i in polybay do
                        (
                            local newfi = [0,0,0] --用于临时存储面的顶点索引,初始化[0，0，0]
                            local fi = getface themesh i
                            newfi.x = (finditem usevert fi.x)+val_count  --根据新的顶点列表编号重新调整面的顶点索引
                            newfi.y = (finditem usevert fi.y)+val_count
                            newfi.z = (finditem usevert fi.z)+val_count
                            append facebuff newfi  
                            /*
                            local visby = #{1..3}  --用于储存该三角面的三边可见性
                            visby[1] = getEdgeVis themesh i 1
                            visby[2] = getEdgeVis themesh i 2
                            visby[3] = getEdgeVis themesh i 3
                            append visEdge visby --加入面的可见性总列表中
                            */
                        )
                        facebitary -= polybay --将已经遍历完的三角面从总遍历表中删除，防止重复
                        findex = ((facebitary as array)[1])  --从更新后的总遍历表中取得一个未处理的面索引号用于下次循环(这里取新表首个索引)
                    )
                    delete themesh  --释放模型的快照资源
                    
                    vertArybuff = vertbuff
                    faceArybuff = facebuff
                    --visEDG = visEdge
                    ok 
                    -------------------------------------------------------------------
                )
            )
        )
    )
    
    on attachedToNode node do
    (
        node.fpos.controller = point3_script()
        mt_node = point size:10 wirecolor:green centermarker:false axistripod:false cross:false box:true name:(uniquename "MatrixPp_MT")
        mt_node.transform.controller = node.transform.controller
        local pos_pt = point size:6 wirecolor:green centermarker:false axistripod:false cross:true box:false name:(uniquename "MatrixPp_pos") pos:mt_node.pos
        node.fpos.controller.addTarget "tpos" pos_pt.pos.controller
        node.fpos.controller.script = "tpos"
    )
    
    on create do
    (
        vertArybuff = #( [-10,-10,0],[10,-10,0],[10,10,0],[-10,10,0], [10,-10,0],[30,-10,0],[30,10,0],[10,10,0] )
        faceArybuff = #( [1,2,3],[1,3,4],[5,6,7],[5,7,8] )
        faceVFI = #(0,4,8)
        faceMTbuff = #( (matrix3 [1,0,0] [0,1,0] [0,0,1] [5,5,0]),(matrix3 [1,0,0] [0,1,0] [0,0,1] [20,0,0]) )
        upd_faceMTbuff = #( (matrix3 [1,0,0] [0,1,0] [0,0,1] [5,5,0]),(matrix3 [1,0,0] [0,1,0] [0,0,1] [20,0,0]) )
    )
    
    on buildMesh do
    (

        local selfmt = matrix3 1
        if mt_node != undefined do
        (
            selfmt = mt_node.transform
        )
        
        local vertAry = #()
        local faceAry = #()
        
        try
        (    
            vertAry = vertArybuff as array
            faceAry = faceArybuff as array
            upd_faceMTbuff = faceMTbuff as array

            local polycount = faceMTbuff.count
            for i in 1 to polycount do
            (
                local fmt = faceMTbuff[i]
                local thepos = fmt.row4
                local fpos_objspace = (fpos*(inverse selfmt))

                --检测距离，采用伪随机，扰乱距离，增加紊乱检测性
                seed (i-95508)
                local tlen = (length (thepos - fpos_objspace))+(random 0.0 randVal)*0.03
                if tlen < TimeVal do
                (
                    --取得一个poly面内所有顶点的编号范围
                    local vi_start = faceVFI[i] + 1  --索引是基于0，所以取出的值+1
                    local vi_end = faceVFI[i+1] 

                    local tp_val = TimeVal - tlen
                    local tp_f_val_0 = tp_val/(tlen as float)
                    --tp_f_val_0 = sqrt tp_f_val_0 --计算开根
                    
                    if tp_f_val_0 >= 1.0 do tp_f_val_0 = 1.0
                    
                    local tp_f_val_1 = 1.0 - tp_f_val_0
                    if tp_f_val_1 <= 0.0 do tp_f_val_1 = 0.0    
                    
                    seed (i+2151)
                    local rot_radius = radius+(random 0.0 randradiu)
                    local trans_mat = transMatrix [0,0,rot_radius]
                    local scale_mat = scaleMatrix [tp_f_val_1,tp_f_val_1,tp_f_val_1]
                    if tp_f_val_1 == 0 do scale_mat.scale = [0,0,0]
                        
                    local rot_mat = matrix3 1
                    
                    
                    --检查脚本编辑面板中的脚本是否开启
                    if txtchk then
                    (
                        --声明全局只读变量
                        global fidx = i  --当前面的索引值
                        global fage_0 = tp_f_val_0
                        global fage_1 = tp_f_val_1
                        try
                        (
                            rot_mat = (execute sc_txt)
                        )
                        catch
                        ( 
                            print (getcurrentexception())
                        )
                        
                    )
                    else
                    (
                        rot_mat = (rotateXmatrix (sp_rot_x*tp_f_val_0))*(rotateYmatrix (sp_rot_y*tp_f_val_0))*(rotateZmatrix (sp_rot_z*tp_f_val_0))
                    )
                    
                    --temp
                    --rot_mat = (rotateXmatrix (sp_rot_x*tp_f_val_0))*(rotateYmatrix (sp_rot_y*tp_f_val_0))*(rotateZmatrix (sp_rot_z*tp_f_val_0))
                    
                    local after_upd_mat = scale_mat*(inverse trans_mat)*rot_mat*trans_mat*fmt
                    local com_mat = (inverse fmt)*after_upd_mat
                    
                    --更新
                    upd_faceMTbuff[i] = after_upd_mat
                    
                    -- 一个poly面内的所有顶点执行合矩阵变换
                    for k in vi_start to vi_end do
                    (
                        vertAry[k] *= com_mat
                    )
                
                    /*
                    --运行后执行
                    if txtchk then
                    (
                        --声明全局只读变量
                        global fidx = i  --当前面的索引值
                        global fage_0 = tp_f_val_0
                        global fage_1 = tp_f_val_1
                        try( execute sc_txt )catch
                        ( 
                            print "MC_Edit Error!!" 
                            txtchk = false
                        )
                    )
                    */
                    
                )
                
            )
            
        )
        catch
        (
            print (getcurrentexception())
            vertAry = #( [0,0,0], [100,0,0], [0,10,0] )
            faceAry = #([1,2,3])
            "Error!"
            --setmesh mesh vertices:vertAry faces:faceAry
        )
        
        setmesh mesh vertices:vertAry faces:faceAry    
        
        if once_update do
        (
            if nummaps >= 3 then
            (
                meshop.setNumMaps mesh nummaps
                meshop.setmapsupport mesh 0 false  --关闭颜色通道
            )
            else
            (
                nummaps = 2
            )
            once_update = false
        )
        
        --*/
        
    )
    
    tool create
    (
        on mousePoint click do
        (
            case click of
            (
                1: (nodeTM.row4 = gridPoint) 
            )
        )
        on mouseMove click do
        (
            case click of
            (
                2: 
                (
                    if altKey then
                    (
                        
                    )
                    else
                    (
                        
                    )
                    
                )
                3: 
                (
                    #stop
                )
            )
        )
    )
)