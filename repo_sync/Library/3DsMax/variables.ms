(
	local pi = "Hello!"
	format "% : %\n" pi ::pi
	fn test x:pi y:::pi = format "% : %\n" x y
	test()
)
--Hello! : 3.14159
--Hello! : 3.14159
--OK

(
	local pi = "Hello!"
	format "% : %\n" pi ::pi
)
--Hello! : 3.14159
--OK

(
	local a = "Hello!"
	format "% : %\n" a ::a
)
--Hello! : undefined


