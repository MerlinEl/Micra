person = {

	"name" : "John",
	"age" : 24,
	"country" : "Brno",
	"lang": "Eng"

}

person.prototype.geNames = function(




)


car = {

	"speed"

}


Person[name:"John Doe" age:49].


--local space
(
	local p1 = p2 = undefined
	(
		struct Person (name, age)
		p1 = Person "Bill" 23
	)
	(
		struct Person (name, age, weight)
		p2 = Person "Natalia" 18 55
	)
	Person = undefined
	format "persons:\n\t1:%\n\t2:%\n" p1 p2
)


--------------
MAX
--------------
struct Person (name, age, country, lang)
p2 = Person "Natalia" 24 "Brno" "Eng"

--------------
JAVASCRIPT
--------------
person = {

	"name" : "John",
	"age" : 24,
	"country" : "Brno",
	"lang": "Eng"
}


struct DynamicDictionary  (

	fn trySetMember key val = (

		format "key:% val:%\n" key val
	)
)

person = DynamicDictionary ()
person.age
