using Autodesk.Max;

namespace Micra.Tools {
    class MxMap {
        public static string GetMapName(IINode node) {

            IMtl mtl = node.Mtl;
            if ( mtl != null ) {
                //Diffuse map channel Number is 0 
                //Write to channel number which you want to get
                ITexmap texMap = mtl.GetSubTexmap(0);
                if ( texMap != null ) {
                    string mapName = ( (IBitmapTex)texMap.GetParamBlock(0).Owner ).MapName;
                    return mapName;
                }
            }
            return string.Empty;
        }
    }
}
