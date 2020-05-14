using Micra.Tools;
using MicraTools.Launcher.Properties;
using Orien.NetUi;
using System.Drawing;
using System.Windows.Forms;

namespace MicraTools.Launcher {
    public partial class Form1 : Form {
        private MxConsole CConsole;
        public Form1() {
            InitializeComponent();
            InitializeProgram();
        }

        private void InitializeProgram() {

            McTooltip tltp = new McTooltip {

                HeaderText = "The Title",
                BodyText = "Button 1. ToolTip with Image",
                FooterText = "For Help press F1",
                BodyImageStretch = true,
                ExtendedMode = true,
                AutoHide = false,
                DebugMode = true,
                BodyTextFont = new Font("Arial", 12, FontStyle.Regular),
                //MaxSize = new Size(100, 300)
                MaxSize = new Size(400, 400)
            };
            tltp.SetToolTip(button1, Resources.tltp_flatten_01);

            //dotNet.loadAssembly(micra.AssemblyDir + "Micra.Tools.dll")
            //doesfileexist(micra.AssemblyDir + "Micra.Tools.dll")
            Autodesk.Max.IGlobal global = Listener.Global;


            CConsole = new MxConsole {
                Owner = this
            };
        }

        private void button2_Click(object sender, System.EventArgs e) {

            CConsole.Log("hello!"); // main console tab
            CConsole.Log("", "The {0} is {1} years old.", "Tifany", 12); // main console tab
            CConsole.Log("The {0} is {1} years old.", new object[] { "Tifany", 12 }); // main console tab
            CConsole.Log("Console", "The {0} is {1} years old.", "Tifany", 12); // main console tab
            CConsole.Log("The {0} is {1} years old.", new object[] { "John", 33 });
            CConsole.Log("Personal", "hello Body"); //ok
            CConsole.Log("Formated", "The {0} is {1} years old.", new object[] { "Monika", 22 });
        }
    }
}
