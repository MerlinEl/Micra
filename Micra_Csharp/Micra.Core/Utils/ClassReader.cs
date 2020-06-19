using Micra.Core.Extensions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace Micra.Core.Utils {
    public class ClassReader {

        /// <summary> Get (Class - Struct) Field by Name </summary>
        public static FieldInfo GetFieldByName(Type classType, string fieldName) => classType.GetField(fieldName);

        /// <summary> Get (Class - Struct) Field value by Name
        ///     <example> 
        ///         <code>
		///             example: 
        ///             var o = ClassReader.GetClassFieldValueByName(typeof(Primitives), "Plane");
		///         </code>
		///     </example>
        ///     <para>param: <paramref name="classType"/></para>
        ///     <para>param: <paramref name="fieldName"/></para>
        /// </summary>
        public static object GetFieldValueByName(Type classType, string fieldName) {

            return classType.GetField(fieldName)?.GetValue(classType);
        }

        /// <summary> Get Public Static Class Names</summary>
        /// ClassReader.GetClassNames(typeof(ClassID)).ToArray()
        /// ClassReader.GetClassNames(typeof(ClassID), BindingFlags.Static).ToArray()
        public static List<string> GetClassNames(Type classType) {

            return GetClassNames(classType, BindingFlags.Static | BindingFlags.Public);
        }
        /// <summary> Get Class Field Names by given value Type
        ///     <example> 
        ///         <code>
        ///             example: 
        ///             <br>ClassReader.GetClassNames(typeof(Primitives), typeof(PrimGeomObjectFactory)).ForEach(</br>
        ///             <br>s => Max.Log("\tPrimitives > PrimGeomObjectFactory:{0}", s);</br>
        ///             <br>);</br>
        ///         </code>
        ///     </example>
        ///     <para>param: <paramref name="classType"/></para>
        ///     <para>param: <paramref name="fieldType"/></para>
        /// </summary>
        public static List<string> GetClassNames(Type classType, Type fieldType) {
            return GetClassNames(classType, BindingFlags.Static | BindingFlags.Public, fieldType);
        }

        public static List<string> GetClassNames(Type classType, BindingFlags bindingFlags) {
            return classType.GetFields(bindingFlags).Select(f => f.Name).ToList();
        }

        public static List<string> GetClassNames(Type classType, BindingFlags bindingFlags, Type fieldType) {
            return classType.GetFields(bindingFlags)
            .Where(f => f.FieldType == fieldType)
            .Select(f => f.Name)
            .ToList();
        }

        /// <summary> Get Node Paramaters which can be accessed from C# (From 3DsMax can be accessed more)</summary>
        public static List<string> GetParamNames(Node n) => n.Object.Params.Select(p => p.Name).ToList();
        /// <summary> Show all C# accesible Nodes parameters</summary>
        public static void ShowParameters(IEnumerable<Node> nodes) {

            Max.Log("Selected Nodes( {0} ) Parameters > ", nodes.Count());
            nodes.ForEach(n => {
                Max.Log("\tObject:{0} type:{1} params:{2}", n.Name, n.GetType().Name, n.Object.Params.Count());
                GetParamNames(n).ForEach(p => Max.Log("\t\tparam:{0}", p));
            });
        }
    }
}
