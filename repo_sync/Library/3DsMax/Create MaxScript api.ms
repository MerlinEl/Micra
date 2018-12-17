/***
Create MaxScript .api file for use with the automcomplete feature of the MaxScript editor.

Created by:
James Haywood
http://apps.jhaywood.com/blog/
***/
(
	filteredSS = stringstream ""
	ss = stringstream ""
	
	apropos "" to:ss
	seek ss 0
	while not eof ss do
	(
		l = readLine ss
	
		if matchPattern l pattern:"*#struct:*" then
		(
			n = (filterString l " ")[1]
			l = readLine ss
			while matchPattern l pattern:"*public,*" do
			(
				format "%.%\n" n (trimLeft (filterString l ":")[1] " ") to:filteredSS
				l = readLine ss
			)
		)
		else if matchPattern l pattern:"*(const *" then
		(
			format "%\n" (filterString l " ")[1] to:filteredSS
		)
	)
	
	filePath = getDir #maxRoot + @"\maxscript.api"
	if not doesFileExist filePath then 
	(
		createFile filePath
	)
	if getFileAttribute filePath #readOnly then
	(
		setFileAttribute filePath #readOnly false
	)
	fStream = openFile filePath mode:"w+"
	format "%" (filteredSS as string) to:fStream
	close fStream
	edit filePath
)


/*
You may or may not know about the autocomplete feature available in the MaxScript 

Editor (as of version 9 or so, I forget when it was changed exactly).  It's very 

helpful when scripting to cut down on typos and to speed things up over all (for 

another way to speed up script creation, check out Johan's blog post about using 

abbreviations).

 To enable it, select "Open Global Options File" in the "Tools" menu.  Then do a search 

for "autocomplete" and change or insert the following lines...

autocompleteword.automatic=1
 autocomplete.*.ignorecase=1
 autocomplete.choose.single=0

 You can see what each line actually does by reading the MaxScript help doc.  After you 

save the file, you'll see the autocomplete popup menu as you type when there is only 

one other word in the current script that mathces what you've typed up to that point.  

Then just press Enter to fill out the rest of the word.  You can also press Ctrl-Enter 

at any time while you're typing to bring up a list of possible matches which you can 

then select from using the up/down arrow keys.

 While that alone is pretty handy, wouldn't it be useful if autocomplete didn't just 

look for words within the current script, but was able to match against any MaxScript 

command too?  Well it can.  You just need to provide an api file for it to use which 

lists all of the commands.  Unfortunately, Autodesk doesn't provide one with Max, but 

I've made a script that will create one for you.

 Download the script below and run it to create the api file.  It will try to save it 

to your Max root folder, but if you run into trouble becuase of Windows UAC settings, 

just modify the script to save it somewhere else, shut down Max, and then move it to 

the root.  Then add the following lines to the global options file...

 autocomplete.*.start.characters=$(chars.alpha)$(chars.numeric)$_@#.
api.*.ms=maxscript.api

 You can actually add more than one api file, for things like custom functions and 

such.  Just create a text file with one word on each line, or a word/period/word 

combination for functions within scructs, and save it to the Max root.  Then and add 

the file name to the above line following a semicolon, like so...

api.*.ms=maxscript.api;mytools.api

 The one problem with using an api file is that it takes precedent over the current 

script, so that you no longer get words from the script you're working on in the 

autocomplete list.  What you can do, though, is if you're beginning to type the name of 

a local function or something that you know already exists in the current script, press 

Ctrl-Enter and you'll see your local word matches.

 One last thing, I'm posting the script to create the api file instead of the api file 

itself because different versions of Max will have different commands available.  So 

this lets you create a new list for every new version of Max.
*/
