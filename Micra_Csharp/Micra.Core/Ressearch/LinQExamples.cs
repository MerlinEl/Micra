using System.Collections.Generic;
using System.Linq;

namespace Micra.Core.Ressearch {
    class LinQExamples {

        public static List<string> FilterDupplicates(List<string> items) {
            List<string> result = new List<string>();
            items.ForEach(str1 => {

                if ( items.Where(str2 => str1 == str2).First() == null ) result.Add(str1);
            });
            return result;
        }
    }
}
