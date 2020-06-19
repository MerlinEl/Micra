using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Micra.Core.Ressearch {
    class CPP_TO_CSHARP_02 {


    }
}

/*
https://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__cpp_ref_class_i_param_block2_html

172 {
  173     // Find the parameter that matches the given name
  174     ParamBlockDesc2* const pbdesc = GetDesc();
  175     if(DbgVerify(pbdesc != nullptr))
  176     {
  177         const int param_index = pbdesc->NameToIndex(paramName);
  178         if(DbgVerify(param_index >= 0))
  179         {
  180             const ParamDef* const param_def = pbdesc->GetParamDefByIndex(param_index);
  181             if(DbgVerify(param_def != nullptr))
  182             {
  183                 return DbgVerify(SetValue(param_def->ID, t, value, tabIndex) != 0);
  184             }
  185         }
  186     }
  187 
  188     return false;
  189 }



{
  // Find the parameter that matches the given name
  ParamBlockDesc2 pbdesc = GetDesc();
  if (DbgVerify(pbdesc != null))
  {
	  int param_index = pbdesc.NameToIndex(paramName);
	  if (DbgVerify(param_index >= 0))
	  {
		  ParamDef param_def = pbdesc.GetParamDefByIndex(param_index);
		  if (DbgVerify(param_def != null))
		  {
			  return DbgVerify(SetValue(param_def.ID, t, value, tabIndex) != 0);
		  }
	  }
  }

  return false;
}

*/
