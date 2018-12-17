ss= stringstream "asdadasasfas,asda,asd,adas\".ad\".d"
while not eof str do print (readDelimitedString ss ",")


path_array = #()
skipToString ss "\""
while not eof ss do 
(
	str=readDelimitedString str ";"
	if str != "\n" then append path_array str
)


print <value> to:<stringstream> 
format "<fmt_string>" {values} to:<stringstream> 

readLine <stringstream
skipToNextLine <stringstream> 

filePos ss --get current pos
seek ss 20 --skip to pos

free ss
close ss
flush ss 


		
		seek str_stream 0 --skip to pos zero
		skipToString str_stream "\""
		local start_pos= filePos str_stream
		skipToString str_stream "\""
		local end_pos= filePos str_stream
		format "start:%\tend:%\n" start_pos end_pos 
		