using Micra.Core.Extensions;
using Micra.Core.Utils;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;

namespace Micra.Core.Prim {

    public class PrimitivesClassGenerator {

        private static string FixName(string str) => str.Replace(" ", "").Replace("-", "_");

        /*public static SceneObject CreateObjectFromString(string expression) {
            var loDataTable = new DataTable();
            var loDataColumn = new DataColumn("Eval", typeof(SceneObject), expression);
            loDataTable.Columns.Add(loDataColumn);
            loDataTable.Rows.Add(0);
            return (SceneObject)( loDataTable.Rows[0]["Eval"] );
        }*/

        public static string CreateStringEnums(List<SceneObject> so) {

            string outStr = "internal static class EParams {\n\t";
            List<string> usedParams = new List<string>() { };
            so.ForEach(o => {

                List<string> paramNames = ClassReader.GetParamNames(o.GetNode());
                Max.Log("obj:{0} params:\n\t{1}", FixName(o.Name), string.Join("\n\t", paramNames));
                List<string> paramFields = paramNames
                    .Where(p => !string.IsNullOrEmpty(p) && usedParams.IndexOf(FixName(p)) == -1).ToList() //prepare collection
                    .Do(p => usedParams.Add(FixName(p))) //add used params in to list
                    .Select(p => string.Format(
                        "public const string {0} = \"{1}\";",
                        FixName(p.FirstCharToUpper()),
                        p.FirstCharToUpper()
                    ))
                    .ToList();
                outStr += string.Join("\n\t", paramFields);
            });
            return outStr + "\n}";
        }

        public static string CreateStringParams(List<string> paramNames) {

            string parameters = "";
            paramNames
                .Where(p => !string.IsNullOrEmpty(p))
                .ForEach(p => {

                    parameters += string.Format(
                    "\tpublic float {0} {{\n" +
                    "\t\tget => (float)parameterBlock[EParams.{0}].Value;\n" +
                    "\t\tset {{ parameterBlock[EParams.{0}].Value = value; }}" +
                    "\t}}" +
                    "}}\n",
                        FixName(p.FirstCharToUpper())
                    );
                });
            return parameters;
        }

        public static string CreateStringClass(SceneObject o) {

            string className = FixName(o.Name);
            List<string> paramNames = ClassReader.GetParamNames(o.GetNode());
            //Max.Log(String.Join("\n\t", paramNames));
            string classString = string.Format(
                "public class P{0} : SceneObject {{\n" +
                    "\tpublic P{0}(SceneObject x) : base(x._Object) {{ _Node = x._Node; }}\n{1}" +
                 "}}",
                 className, CreateStringParams(paramNames)
           );
            return classString.Replace("{{", "{").Replace("}}", "}"); //remove double parentheses (brackets)
        }

        public static string CreatePrimitiveCommandsList() {
            //var o = Primitives.Box.Create();
            FieldInfo[] fields = typeof(Primitives).GetFields(BindingFlags.Static | BindingFlags.Public);
            string names = "";
            foreach ( FieldInfo f in fields ) {
                names += string.Format("\nMax.Log(\"create:{0}\");\tso.Add(Primitives.{0}.Create());", f.Name);
            }
            return names;
        }
        public static string GetObjectClass(Node n) => n.ClassOf();

        public static string GenerateClass(SceneObject obj) {

            return CreateStringClass(obj);
        }

        public static string GenerateClasses() {

            List<SceneObject> so = new List<SceneObject>() { };

            Max.Log("create:Teapot"); so.Add(Primitives.Teapot.Create());
            Max.Log("create:Box"); so.Add(Primitives.Box.Create());
            Max.Log("create:Sphere"); so.Add(Primitives.Sphere.Create());
            Max.Log("create:Cylinder"); so.Add(Primitives.Cylinder.Create());
            //Max.Log("create:Wave"); so.Add(Primitives.Wave.Create());
            Max.Log("create:Torus"); so.Add(Primitives.Torus.Create());
            //Max.Log("create:Donut"); so.Add(Primitives.Donut.Create());
            //Max.Log("create:GSphere"); so.Add(Primitives.GSphere.Create());
            Max.Log("create:Hedra"); so.Add(Primitives.Hedra.Create());
            Max.Log("create:Loft"); so.Add(Primitives.Loft.Create());
            //Max.Log("create:Pipe"); so.Add(Primitives.Pipe.Create());
            //Max.Log("create:Pyramid"); so.Add(Primitives.Pyramid.Create());
            Max.Log("create:Tube"); so.Add(Primitives.Tube.Create());
            Max.Log("create:PointHelper"); so.Add(Primitives.PointHelper.Create());
            //Max.Log("create:Bend"); so.Add(Primitives.Bend.Create());
            //Max.Log("create:Taper"); so.Add(Primitives.Taper.Create());
            //Max.Log("create:Twist"); so.Add(Primitives.Twist.Create());
            //Max.Log("create:Extrude"); so.Add(Primitives.Extrude.Create());
            //Max.Log("create:Smooth"); so.Add(Primitives.Smooth.Create());
            Max.Log("create:Circle"); so.Add(Primitives.Circle.Create());
            Max.Log("create:Ellipse"); so.Add(Primitives.Ellipse.Create());
            Max.Log("create:Helix"); so.Add(Primitives.Helix.Create());
            Max.Log("create:LinearShape"); so.Add(Primitives.LinearShape.Create());
            //Max.Log("create:LinearWave"); so.Add(Primitives.LinearWave.Create());
            Max.Log("create:Polygon"); so.Add(Primitives.Polygon.Create());
            //Max.Log("create:Plane"); so.Add(Primitives.Plane.Create());
            Max.Log("create:Rectangle"); so.Add(Primitives.Rectangle.Create());
            //Max.Log("create:SineWave"); so.Add(Primitives.SineWave.Create());
            Max.Log("create:SimpleCamera"); so.Add(Primitives.SimpleCamera.Create());
            Max.Log("create:LookAtCamera"); so.Add(Primitives.LookAtCamera.Create());
            Max.Log("create:OmniLight"); so.Add(Primitives.OmniLight.Create());
            Max.Log("create:SpotLight"); so.Add(Primitives.SpotLight.Create());
            //Max.Log("create:SunLight"); so.Add(Primitives.SunLight.Create());
            //Max.Log("create:LookAtCtrl"); so.Add(Primitives.LookAtCtrl.Create());
            //Max.Log("create:Path"); so.Add(Primitives.Path.Create());

            //so.ForEach(o => Max.Log("node:{0} params:\n{1}", o.Name, String.Join("\n\t",Utility.GetParamNames(o.GetNode()))));
            string outStr = CreateStringEnums(so) + "\n";
            so.ForEach(o => outStr += CreateStringClass(o) + "\n");
            return outStr;
        }
    }
}
