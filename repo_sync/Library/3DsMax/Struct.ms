struct mcTransferData (dName, btName, command, str)

x= mcTransferData dName:"rene"

-------------------------------------------

struct foo
(
	name,age
)
am = foo()
cn = (foo name:"rene" age:33)


--DenisT
--some tricks with struct functions:

struct testStruct 
(
	a = 2, b = 3, ac, bc, 
	fn cc = ac()+bc(),
	fn aa = a*a,
	fn ab = aa()+b,
	fn bb = aa()*b,
	on create do
	(
		ac = aa
		bc = ab
	)
)
theStruct = testStruct()
theStruct.ab()
theStruct.cc()
theStruct.a = 4
theStruct.b = 5
theStruct.cc()
theStruct.ac = theStruct.bb
theStruct.cc()