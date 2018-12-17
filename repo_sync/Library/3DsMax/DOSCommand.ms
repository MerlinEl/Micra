pokud ma cesta mezery nebo dlouha jmena pouzij dvojty string

DOSCommand  "\"" + "C:\Program Files\Autodesk\3DsMax" + "\""

fn copyDirTree indir outdir hidden:true exceptempty:false owerwritereadonly:true existingonly:false silent:true =
(
	--check path end slash
	trimRight inpath "c:\\temp/" "\\/"
	trimRight outpath "c:\\temp/" "\\/"
	inpath  += "\\"
	outpath += "\\"
	
	local cmd = "XCOPY   /I " +
		(if exceptempty       then "/S " else "/E ") + 
		(if hidden            then "/H " else ""  ) + 
		(if owerwritereadonly then "/R " else ""  ) + 
		(if existingonly      then "/U " else ""  ) + 
		(if silent            then "/Y " else " "  ) + 
		indir + " " + outdir

	format "cmd:%\n" cmd
	DOSCommand cmd
)

copyDirTree "C:\\Temp\\test" "C:\\Temp\\test2" exceptempty:true

XCOPY
/E           Copies directories and subdirectories, including empty ones.
/S           Copies directories and subdirectories except empty ones.
/I           If destination does not exist and copying more than one file,
               assumes that destination must be a directory.
/H           Copies hidden and system files also.
/R           Overwrites read-only files.
/Y           Suppresses prompting to confirm you want to overwrite an
             existing destination file.
/D:m-d-y     Copies files changed on or after the specified date.
             If no date is given, copies only those files whose
             source time is newer than the destination time.
/T           Creates directory structure, but does not copy files. Does not
              include empty directories or subdirectories. /T /E includes
              empty directories and subdirectories.
/U           Copies only files that already exist in destination.
			  
			  

DOSCommand ("ren " + FolderName + " \""  +  text + "\"") --rename dir
DOSCommand ("rd /s /q \"" + FolderPath + "\"") --deleteFile dir tree

or

DOSCommand ( "rd "+"\""+Path+"\""+" /s /q")


DOSCommand "delete c:\\temp\\foo.dat"
DOSCommand "del D:\\3dsmax7\\shaders\\.svn\\*.*"

Deletes one or more files.

DEL [/P] [/F] [/S] [/Q] [/A[[:]attributes]] names
ERASE [/P] [/F] [/S] [/Q] [/A[[:]attributes]] names
names	Specifies a list of one or more files or directories. Wildcards may be used to delete multiple files. If a directory is specified, all files within the directory will be deleted.
/P	Prompts for confirmation before deleting each file.
/F	Force deleting of read-only files.
/S	Delete specified files from all subdirectories.
/Q	Quiet mode, do not ask if ok to delete on global wildcard
/A	Selects files to delete based on attributes
attributes	

R  Read-only files            S  System files
H  Hidden files               A  Files ready for archiving
-  Prefix meaning not


Syntax:

MOVE [/Y|/-Y] [d:][path]filename[,[d:][path]filename[...]] destination

Purpose: Moves one or more files to the location you specify. Can also be used to rename directories.
Discussion

To move a file or files, you specify the name and location of the file or 
files you want to move followed by the destination. The destination specifies the new location of the file, 
or the new name of the directory. The destination can consist of a drive letter followed by a colon, a directory name, 
or a combination. If you are moving only one file, you can also specify a filename. If you are moving more than one file, 
the destination must be a directory name. 
If you move a file to an existing file, it will be overwritten.
Options

/Y - Use this option if you want MOVE to replace existing file(s) without prompting you for a confirmation. 
Otherwise, the replacement will not be made until you confirm it. If you use MOVE as part of a batch file, 
existing files will be replaced without a confirmation prompt. This option will override all defaults as well as 
the current setting of the COPYCMD environment variable.

/-Y - Use this option if you want MOVE to provide a confirmation prompt before replacing an existing file. 
This option will override all defaults as well as the current setting of the COPYCMD environment variable.

Examples

If you want to move two files named LETTER1 and LETTER2 from the current directory to the \MEMOS directory on drive C, enter the following:

move letter1, letter2 c:\memos

To rename the 89MEMOS directory on drive C to 90MEMOS, enter the following:

move c:\89memos c:\90memos



Windows95 obsahuje tyto DOS pr(íkazy:

 

attrib                                                   nastavení pr(íznaku* souboru* (externí)

break                                                  nastavení rozeznání Ctrl+C

cd                                                        zme(na/zobrazení aktuální adresár(e

chcp                                                   zobrazení/zme(na aktuální kódové stránky

chdir                                                   totéž co cd

chkdsk                                               kontrola stavu disku, doporuc(ená náhrada - scandskw, (externí)

cls                                                       smazání obsahu obrazovky

command                                           spušte(ní nového COMMAND.COM, (externí)

copy                                                   kopírování souboru*

ctty                                                     zme(na použitého terminálového zar(ízení

date                                                    zobrazení/nastavení systémového data

drvspace                                            komprimace disku*
, (externí)

debug                                                 ladící program
, (externí)

defrag                                                 defragmentace disku, (externí)

del                                                       mazání souboru*

deltree                                                mazání adresár(u*, (externí)

dir                                                       zobrazení obsahu adresár(u*

diskcopy                                            kopírování disket, (externí)

doskey                                               zavedení historie DOS pr(íkazu*, (externí)

edit                                                     textový editor pro ASCII soubory, (externí)

emm386                                              pame(t(ový manažer, (externí)

erase                                                   viz del

exit                                                      opušte(ní COMMAND.COM, DOS okna

expand                                               dekomprimace komprimovaných souboru*, (externí)

fc                                                         porovnání dvou souboru*, (externí)

fdisk                                                   zme(ny/zobrazení rozde(lení oblastí disku*, (externí)

find                                                     vyhledávání, (externí)

for                                                       opakované spoušte(ní pr(íkazu*

format                                                 formátování disku* a disket, (externí)

keyb                                                   nastavování klávesnice, (externí)

label                                                    nastavení jmenovky disku, (externí)

lh                                                         viz loadhigh

loadfix                                                program bude zaveden na prvních 64K pame(ti, (externí)

loadhigh                                            program je zaveden do horní pame(ti

md                                                       vytvár(ení adresár(u*

mem                                                    zobrazení množství pame(ti, (externí)

mkdir                                                  viz md

mode                                                  konfigurace zar(ízení, (externí)

more                                                   postupné zobrazování výstupu

move                                                  pr(esuny souboru*, (externí)

nlsfunc                                               zavedení podpory národních jazyku*
, (externí)

path                                                    urc(ení/zobrazení vyhledávací cesty

prompt                                               vzhled pr(íkazové r(ádky

rd                                                        zrušení adresár(e

ren                                                      pr(ejmenování

rename                                               viz ren

rmdir                                                   viz rd

scandisk                                            kontrola a oprava disku*, (externí)

set                                                       nastavení systémových prome(nných

setver                                                 práce s tabulkou verzí, (externí)

smartdrv                                            disková vyrovnávací pame(t(, (externí)

sort                                                     tr(íde(ní, (externí)

start                                                    spoušte(ní programu*, (externí)

subst                                                  asociace cesty s diskem, (externí)

sys                                                      vytvor(ení startovacího disku, (externí)

time                                                     zobrazení/nastavení systémového c(asu

type                                                    zobrazení obsahu textového souboru

ver                                                      zobrazení verze operac(ního systému

verify                                                  nastavení ove(r(ování zápisu* souboru*

vol                                                      zobrazení jména a ser.c(ísla disku

xcopy                                                 kopírování souboru* a adresár(u*, (externí)