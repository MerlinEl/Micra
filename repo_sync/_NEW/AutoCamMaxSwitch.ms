/*
http://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_779FD7AC_953D_4567_B2A8_60B1D8695B95_htm
dotNetClass

dotNetObject

dotNetControl

dotNetMethod

dotNetMXSValue
*/



fn AutoCamMaxSwitch state = (
	
	--define source file and backup file 
	local stdplugs_dir = (getDir #maxroot) + "\\stdplugs" 
	local gup_file = stdplugs_dir + "\\AutoCamMax.gup" 
	local gup_bkfile = stdplugs_dir + "\\AutoCamMax.gup.bak" 
	local dotnet_file = dotNetObject "System.IO.FileInfo" gup_file
	local dotnet_bkfile = dotNetObject "System.IO.FileInfo" gup_bkfile

	--Get a FileSecurity object that represents the current security settings.
	local fileAccessControl  = dotnet_file.GetAccessControl()
	
	--Add the FileSystemAccessRule to the security settings. 
	local rights = dotNetClass "System.Security.AccessControl.FileSystemRights"
	local types = dotNetClass "System.Security.AccessControl.AccessControlType"
	local sid_type= dotNetClass "System.Security.Principal.WellKnownSidType"
	local null = dotNetObject "System.String" "undefined"
	
	--System.Security.Principal.SecurityIdentifier <System.Security.Principal.WellKnownSidType>sidType <System.Security.Principal.SecurityIdentifier>domainSid
	local everyone = dotNetObject "System.Security.Principal.SecurityIdentifier" princ.WorldSid Account
	
	/*local NTAccountType = dotNetClass "System.Security.Principal.NTAccount"
	local fileOwner = fileAccessControl.getOwner NTAccountType
	local Account = fileOwner.value
	local access_rule = dotNetObject "System.Security.AccessControl.FileSystemAccessRule" fileOwner.value rights.FullControl types.Allow*/
	
	--"Creator Owner", "Creator Group" 
	--new SecurityIdentifier(WellKnownSidType.BuiltinAdministratorsSid, null).Translate(typeof(NTAccount))
	--$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $everyone, "Full", "ContainerInherit,ObjectInherit", "None", "Allow"

	local access_rule = dotNetObject "System.Security.AccessControl.FileSystemAccessRule" "everyone" rights.FullControl types.Allow
	
	--.AddAccessRule <System.Security.AccessControl.FileSystemAccessRule>rule
	fileAccessControl.AddAccessRule(access_rule)
	
	--Set the new access settings.
	dotnet_file.SetAccessControl(fileAccessControl)
	
	--rename file
	dotnet_file.MoveTo(dotnet_bkfile.FullName) 
		

	format "file:% exists:% IsReadOnly:% Attributes:%\n" file file.exists file.IsReadOnly file.Attributes
	/*if state then (
		
		if doesFileExist gup_bkfile	do (
			
			--rformat "renaming:%\n" (enameFile gup_bkfile gup_file) --not works
			messageBox "AutoCamMax is enabled. To teake efect please restart 3DsMax"
		)
	) else (
	
		if doesFileExist gup_file	do (
			
			--format "renaming:%\n" (renameFile gup_file gup_bkfile) --not works
			messageBox "AutoCamMax is disabled. To teake efect please restart 3DsMax."
		)
	)*/
)

AutoCamMaxSwitch false --diasable
--AutoCamMaxSwitch true --enable


/*
using System;
using System.IO;
using System.Security.AccessControl;

namespace FileSystemExample
{
    class FileExample
    {
        public static void Main()
        {
            try
            {
                string FileName = "c:/test.xml";

                Console.WriteLine("Adding access control entry for " + FileName);

                // Add the access control entry to the file.
                // Before compiling this snippet, change MyDomain to your 
                // domain name and MyAccessAccount to the name 
                // you use to access your domain.
                AddFileSecurity(FileName, @"MyDomain\MyAccessAccount", FileSystemRights.ReadData, AccessControlType.Allow);

                Console.WriteLine("Removing access control entry from " + FileName);

                // Remove the access control entry from the file.
                // Before compiling this snippet, change MyDomain to your 
                // domain name and MyAccessAccount to the name 
                // you use to access your domain.
                RemoveFileSecurity(FileName, @"MyDomain\MyAccessAccount", FileSystemRights.ReadData, AccessControlType.Allow);

                Console.WriteLine("Done.");
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }

        }

        // Adds an ACL entry on the specified file for the specified account.
        public static void AddFileSecurity(string FileName, string Account, FileSystemRights Rights, AccessControlType ControlType)
        {
            // Create a new FileInfo object.
            FileInfo fInfo = new FileInfo(FileName);

            // Get a FileSecurity object that represents the 
            // current security settings.
            FileSecurity fSecurity = fInfo.GetAccessControl();

            // Add the FileSystemAccessRule to the security settings. 
            fSecurity.AddAccessRule(new FileSystemAccessRule(Account,
                                                            Rights,
                                                            ControlType));

            // Set the new access settings.
            fInfo.SetAccessControl(fSecurity);

        }

        // Removes an ACL entry on the specified file for the specified account.
        public static void RemoveFileSecurity(string FileName, string Account, FileSystemRights Rights, AccessControlType ControlType)
        {
            // Create a new FileInfo object.
            FileInfo fInfo = new FileInfo(FileName);

            // Get a FileSecurity object that represents the 
            // current security settings.
            FileSecurity fSecurity = fInfo.GetAccessControl();

            // Add the FileSystemAccessRule to the security settings. 
            fSecurity.RemoveAccessRule(new FileSystemAccessRule(Account,
                                                            Rights,
                                                            ControlType));

            // Set the new access settings.
            fInfo.SetAccessControl(fSecurity);

        }
    }
}
*/



/*
	--<System.String>identity  CREATOR OWNER, 
	--AddFileSecurity(FileName, @"MyDomain\MyAccessAccount", FileSystemRights.ReadData, AccessControlType.Allow);
	local NTAccountType = dotNetClass "System.Security.Principal.NTAccount"
	local fileOwner = fileAccessControl.getOwner NTAccountType
	local Account = fileOwner.value
fn create_share folderPath =
(
	HiddenDosCommand ("mkdir "+folderPath)
	HiddenDosCommand ("net share " + (pathConfig.stripPathToLeaf folderPath) + "=" + "\"" + folderPath + "\"" + " /UNLIMITED")
)

create_share (sysInfo.tempdir + "test_folder")



fn create_share folderPath =
(
	HiddenDosCommand ("mkdir "+folderPath)
	HiddenDosCommand ("net share " + (pathConfig.stripPathToLeaf folderPath) + "=" + "\"" + folderPath + "\"" + " /GRANT:Everyone,FULL")
)

fn create_share folderPath =
(
	HiddenDosCommand ("mkdir "+folderPath)
	HiddenDosCommand ("net share " + (pathConfig.stripPathToLeaf folderPath) + "=" + "\"" + folderPath + "\"" +@" /GRANT:Everyone,FULL")
)

fn doesFolderExistDNfn folderPath = (
	local sioDir = dotNetClass "System.IO.Directory"
	(SIODir.Exists folderPath)
)
fn create_share folderPath =(
	if not doesFolderExistDNfn folderPath do
		makeDir folderPath
[B]		Universal_Everyone = "Everyone"--"???" 
	LocaleCode_Page = 866[/B]
	batchCommandBuffer = #("@ECHO OFF", "net share " + (pathConfig.stripPathToLeaf folderPath) + "=" + "\"" + folderPath + "\"" + " /UNLIMITED"+" /GRANT:" + Universal_Everyone + ",FULL", "cacls " + "\"" + folderPath + "\"" + " /e /p " + Universal_Everyone + ":f")
	print (batchCommandBuffer as string)
	(dotnetclass "System.IO.File").WriteAllLines (sysInfo.tempdir +"share_folder.bat") batchCommandBuffer ((dotNetClass "System.Text.Encoding").GetEncoding(LocaleCode_Page))
	ShellLaunch (sysInfo.tempdir +"\\share_folder.bat") ""
)
create_share (sysInfo.tempdir + "test_folder")

https://forums.cgsociety.org/t/create-and-share-a-folder-with-maxscript/1707543/27
https://msdn.microsoft.com/library/system.text.encoding%28v=vs.110%29.aspx
*/




/*
fn CreateSecurityOpsAssembly =
(
source  = ""
source += "using System;
"
source += "using System.IO;
"
source += "using System.Security.Principal;
"
source += "using System.Security.AccessControl;
"
source += " 
"
source += "namespace SystemSecurity
"
source += "{
"
source += "    public class AccessOps
"
source += "    {
"
source += "        public bool CreateSharedDirectory(String path)
"
source += "        {
"
source += "            if (!Directory.Exists(path))
"
source += "            {
"
source += "                DirectoryInfo info = Directory.CreateDirectory(path);
"
source += "                if (!info.Exists) return false;
"
source += "            }
"
source += "            DirectorySecurity sec = Directory.GetAccessControl(path);
"
source += "       
"
source += "            SecurityIdentifier everyone = new SecurityIdentifier(WellKnownSidType.WorldSid, null);
"
source += "            sec.AddAccessRule(new FileSystemAccessRule(everyone, 
"
source += "                FileSystemRights.Modify | FileSystemRights.Synchronize, 
"
source += "                InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit, 
"
source += "                PropagationFlags.None, AccessControlType.Allow));
"
source += "            Directory.SetAccessControl(path, sec);
"
source += "            return true;
"
source += "        }
"
source += "    }
"
source += "}
"


	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"

	compilerParams.ReferencedAssemblies.AddRange #("system.dll", "mscorlib.dll")

	compilerParams.GenerateInMemory = on
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	
	assembly = compilerResults.CompiledAssembly
	assembly.CreateInstance "SystemSecurity.AccessOps"
)
global SecurityOps = CreateSecurityOpsAssembly()

/*
SecurityOps.CreateSharedDirectory @"c:	emp\sec\"
*/
*/


