using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Micra.Core {
    public class EnumPlugins {
        public enum AccesType : int {

            ACC_PUBLIC = 1,
            ACC_PRIVATE = 2,
            ACC_ALL = ACC_PUBLIC|ACC_PRIVATE
        }
    }
}
