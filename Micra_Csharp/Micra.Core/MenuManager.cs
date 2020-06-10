//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System.Collections.Generic;

namespace Micra.Core {
    public static class MenuManager {
        static readonly IIMenuManager mgr;

        static MenuManager() {
            mgr = Kernel._Interface.MenuManager;
        }

        public static Menu FindMenu(string name) {
            IIMenu m = mgr.FindMenu(name);
            if ( m == null )
                return null;
            return new Menu(m);
        }

        public static void UpdateMenuBar() {
            mgr.UpdateMenuBar();
        }

        public static void RegisterMenu(Menu menu) {
            mgr.RegisterMenu(menu._Menu, 0);
        }

        public static Menu MainMenuBar {
            get { return new Menu(mgr.MainMenuBar); }
        }

        public static Menu CreateMenuFromActions(string name, IEnumerable<ActionItem> actions) {
            Menu menu = FindMenu(name);

            if ( menu != null ) {
                mgr.UnRegisterMenu(menu._Menu);
                Kernel._Global.ReleaseIMenu(menu._Menu);
            }

            menu = new Menu {
                Title = name
            };
            RegisterMenu(menu);

            foreach ( var a in actions )
                menu.AddItem(new MenuItem(a));

            MenuItem item = new MenuItem {
                Title = name,
                SubMenu = menu
            };
            MainMenuBar.AddItem(item);
            UpdateMenuBar();
            return menu;
        }
    }

    public class Menu {
        readonly IIMenu menu;

        public IIMenu _Menu { get { return menu; } }

        public Menu(IIMenu m) { menu = m; }
        public Menu() : this(Kernel._Global.IMenu) { }

        public IEnumerable<MenuItem> Items {
            get {
                for ( int i = 0; i < menu.NumItems; ++i )
                    yield return new MenuItem(menu.GetItem(i));
            }
        }

        public string Title {
            get { return menu.Title; }
            set { menu.Title = value; }
        }

        public string CustomTitle {
            get { return menu.CustomTitle; }
            set { menu.CustomTitle = value; }
        }

        public bool ShowTitle {
            get { return menu.ShowTitle; }
            set { menu.ShowTitle = value; }
        }

        public bool UseCustomTitle {
            get { return menu.UseCustomTitle; }
            set { menu.UseCustomTitle = value; }
        }

        public void InsertItem(MenuItem item, int position) {
            menu.AddItem(item._Item, position);
        }

        public void AddItem(MenuItem item) {
            InsertItem(item, menu.NumItems);
        }

        public void Delete(MenuItem item) {
            menu.RemoveItem(item._Item);
        }

        public void RemoveAt(int position) {
            menu.RemoveItem(position);
        }
    }

    public class MenuItem {
        readonly IIMenuItem item;
        public IIMenuItem _Item { get { return item; } }
        public MenuItem(IIMenuItem item) { this.item = item; }
        public MenuItem() : this(Kernel._Global.IMenuItem) { }
        public MenuItem(ActionItem item) : this() { ActionItem = item; Title = item.MenuText; }

        public ActionItem ActionItem { get { return new ActionItem(item.ActionItem); } set { item.ActionItem = value._ActionItem; } }
        public bool Checked { get { return item.Checked; } set { item.Checked = value; } }
        public bool ExecuteAction() { return item.ExecuteAction; }
        public string Title { get { return item.Title; } set { item.Title = value; } }
        public Menu SubMenu { get { return new Menu(item.SubMenu); } set { item.SubMenu = value._Menu; } }
    }
}
