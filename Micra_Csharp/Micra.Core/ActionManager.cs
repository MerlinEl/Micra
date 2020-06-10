using Autodesk.Max;
using System.Collections.Generic;

namespace Micra.Core {
    /// <summary>
    /// Provides access to custom actions and custom action tables.
    /// </summary>
    public static class ActionManager {
        public static IEnumerable<ActionItem> Actions {
            get {
                foreach ( var at in ActionTables )
                    foreach ( var a in at.Actions )
                        yield return a;
            }
        }

        public static IEnumerable<ActionTable> ActionTables {
            get {
                for ( int i = 0; i < Kernel._Interface.ActionManager.NumActionTables; ++i )
                    yield return new ActionTable(Kernel._Interface.ActionManager.GetTable(i));
            }
        }
    }

    /// <summary>
    /// Wraps a ActionTable in the 3ds Max SDK. 
    /// </summary>
    public class ActionTable {
        readonly IActionTable at;

        public IActionTable _ActionTable { get { return at; } }
        public ActionTable(IActionTable at) { this.at = at; }

        public IEnumerable<ActionItem> Actions {
            get {
                for ( int i = 0; i < at.Count; ++i )
                    yield return new ActionItem(at[i]);
            }
        }

        public void Append(ActionItem action) { at.AppendOperation(action._ActionItem); }
        public void Delete(ActionItem action) { at.DeleteOperation(action._ActionItem); }
    }

    /// <summary>
    /// Wraps an ActionItem in the 3ds Max SDK. 
    /// </summary>
    public class ActionItem {
        readonly IActionItem ai;

        public IActionItem _ActionItem { get { return ai; } }

        public ActionItem(IActionItem ai) { this.ai = ai; }

        public string ButtonText { get { return ai.ButtonText; } }
        public string Category { get { return ai.CategoryText; } }
        public string MenuText { get { return ai.MenuText; } }
        public string Description { get { return ai.DescriptionText; } }
        public bool IsDynamicAction { get { return ai.IsDynamicAction; } }

#if MAX_2012
        public int ID { get { return ai.Id_; } }
        public bool IsChecked { get { return ai.IsChecked_; } }
        public bool IsEnabled { get { return ai.IsEnabled_; } }
#else
        public int ID { get { return ai.Id_; } }
        public bool IsChecked { get { return ai.IsChecked_; } }
        public bool IsEnabled { get { return ai.IsEnabled_; } }
#endif

        public bool IsItemVisible { get { return ai.IsItemVisible; } }
        public string ShortcutString { get { return ai.ShortcutString; } }
        public ActionTable Table { get { return new ActionTable(ai.Table); } set { ai.Table = value._ActionTable; } }

        public bool Execute() { return ai.Execute(); }
    }
}
