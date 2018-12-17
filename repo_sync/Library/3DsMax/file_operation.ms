fn recordFileToStream fpath =
(
	f = openfile  fpath
	while not eof f do -- read until reach end of file
	(
		line=readline f
		--if line[1] == "[DefaultPath]" do print f
		if line == "[DefaultPath]" then print "Found" else print "Not Found"
	)
)