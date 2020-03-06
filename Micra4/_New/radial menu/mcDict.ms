struct mcDict  (  
    private  
    table = #(),  
    fn binSort a b =  (  
        if a[1] > b[1] then 1  
        else if a[1] < b[1] then -1  
        else 0  
    ),  
    fn formatDic dic level:0 spaces:4 =  (  
        strm = "\n" as stringStream  
        padding = ""  
        if level != 0 then  (  
            for a=1 to level do for b=1 to spaces do padding += " "  
        )  
        for k in (dic.keys()) do  (  
            val = dic.getK k  
            case (classof val) of  
            (  
                (mcDict):format "%%:\n%" padding k (formatDic val level:(level+1) spaces:spaces) to:strm  
                default:format "%%:%\n" padding k val to:strm  
            )  
        )  
        (strm as string)  
    ),    
    public  
    fn count = keys.count,  
    fn getK k =   (  
        val = bsearch #(k) table binSort  
        if val == undefined then return val  
        val[2]  
  
    ),  
    fn setK k v =  (  
        val = bsearch #(k) table binSort  
        if val == undefined then  
        (  
            append table #(k,v)  
            qsort table binSort  
            return this  
        )  
        val[2] = v  
        this  
    ),  
    fn hasK k =  (  
        t = case (bsearch #(k) table binSort) of  
        (  
            (undefined):false  
            default:true  
        )  
        t  
    ),  
    fn delK k =  (  
        indx --findItem keysL (k as name)  
        for i=1 to table.count where table[i][1] == k do  
        (  
            indx = i  
            exit  
        )  
        if indx == 0 then throw ("there is no key "+k+" in dictionary")  
        deleteItem table indx  
        this  
    ),  
    fn keys =  (  
        out = for k in table collect k[1]  
        out  
    ),  
    fn pprint =  (  
        print (formatDic this)  
        ok  
    )  
)  

/*
--make the dictionary  
dic = mcDict()  
--set keys  
dic.setK "pappa" 9999  
--embeded dictonaries  
dic.setK "powers" (mcDict())  
dic.setK "object" (sphere())  
--set key in  the embeded dictionary  
(dic.getK "powers").setK "lazerEyes" true  
(dic.getK "powers").setK "bulletProof" true  
--query the available keys  
print "------keys------"  
print (dic.keys())  
print "----------------"  
  
--loop throug a dictionary  
print "print keys and values"  
for k in dic.keys() do format "%:%\n" k (dic.getK k)  
  
print "preaty print"  
--prety print the dictionary  
dic.pprint() 
*/