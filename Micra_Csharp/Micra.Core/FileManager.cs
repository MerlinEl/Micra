//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//

namespace Micra.Core {
    /// <summary>
    /// Contains global functions related to working with files.
    /// </summary>
    public static class FileManager {
        public static void Open() { Kernel._Interface.FileOpen(); }
        public static bool Save() { return Kernel._Interface.FileSave; }
        public static void SaveSelected() { Kernel._Interface.FileSaveSelected(); }
        public static void SaveSelected(string s) { Kernel._Interface.FileSaveSelected(s); }
        public static bool SaveAs(string s) { return Kernel._Interface.SaveToFile(s, true, false) != 0; }
        public static bool Open(string s) { return Kernel._Interface.LoadFromFile(s, true) != 0; }
        public static void Merge() { Kernel._Interface.FileMerge(); }
        public static void Hold() { Kernel._Interface.FileHold(); }
        public static void Fetch() { Kernel._Interface.FileFetch(); }
        public static bool Import() { return Kernel._Interface.FileImport; }
        public static bool Export() { return Kernel._Interface.FileExport; }
        public static bool Import(string s) { return Kernel._Interface.ImportFromFile(s, true, null); }
        public static bool Export(string s) { return Kernel._Interface.ExportToFile(s, true, 0, null); }
        public static string CurFileName { get { return Kernel._Interface.CurFileName; } }
        public static string CurFilePath { get { return Kernel._Interface.CurFilePath; } }
    }
}
