
-- https://help.autodesk.com/view/3DSMAX/2016/ENU/?guid=__files_GUID_9588A886_A811_4C05_9A07_B6A68C969050_htm
-- NOTE 获取当前脚本的路径
-- SCRIPT_PATH = getSourceFileName()

-- http://help.autodesk.com/view/3DSMAX/2015/ENU/?guid=__files_GUID_0EE531B2_6FF8_4D0B_ACA1_5400E0B9D604_htm
-- NOTE 获取当前脚本的文件夹
-- script_folder = getFilenamePath(script_path)

-- NOTE 设置 utf-8 保存 | 避免中文显示乱码
python.Execute "
import MaxPlus as ms
if not ms.PreferencesFileEncoding.LegacyFilesCanBeStoredUsingUTF8():
    ms.PreferencesFileEncoding.SetLegacyFilesCanBeStoredUsingUTF8(True)
"

macroScript OP
category: "OP FBX Export"
tooltip: "批量导出FBX工具"
(
    -- NOTE 运行 Python 代码
    python.Execute "
__author__ =  'timmyliang'
__email__ =  '820472580@qq.com'
__date__ = '2019-11-26 14:52:34'

u'''
MoreFun - FBX导出工具
简化 3dsMax FBX 导出流程
'''

import os
import sys
import tempfile
try:
    from PySide.QtCore import *
    from PySide.QtGui import *
except:
    from PySide2.QtWidgets import *
    from PySide2.QtCore import *
    from PySide2.QtGui import *

import MaxPlus
import pymxs
import json
from pymxs import runtime as rt

# NOTE 临时文件记录选择的路径
SCRIPT_PATH = os.path.join(tempfile.gettempdir(),\"MF_FBXEXP_PATH.txt\")

class Ui_Form(object):
    def setupUi(self, Form):
        Form.setObjectName('Form')
        Form.resize(349, 184)
        Form.setWhatsThis('')
        self.verticalLayout = QVBoxLayout(Form)
        self.verticalLayout.setObjectName('verticalLayout')
        self.Options_BTN = QPushButton(Form)
        self.Options_BTN.setObjectName('Options_BTN')
        self.verticalLayout.addWidget(self.Options_BTN)
        self.horizontalLayout = QHBoxLayout()
        self.horizontalLayout.setObjectName('horizontalLayout')
        self.label = QLabel(Form)
        self.label.setObjectName('label')
        self.horizontalLayout.addWidget(self.label)
        self.Path_LE = QLineEdit(Form)
        self.Path_LE.setObjectName('Path_LE')
        self.horizontalLayout.addWidget(self.Path_LE)
        self.Path_BTN = QPushButton(Form)
        self.Path_BTN.setObjectName('Path_BTN')
        self.horizontalLayout.addWidget(self.Path_BTN)
        self.verticalLayout.addLayout(self.horizontalLayout)
        self.Export_BTN = QPushButton(Form)
        self.Export_BTN.setObjectName('Export_BTN')
        self.verticalLayout.addWidget(self.Export_BTN)
        spacerItem = QSpacerItem(20, 40, QSizePolicy.Minimum, QSizePolicy.Expanding)
        self.verticalLayout.addItem(spacerItem)

        self.retranslateUi(Form)
        QMetaObject.connectSlotsByName(Form)

    def retranslateUi(self, Form):
        Form.setWindowTitle(u'MoreFun - FBX导出工具')
        self.Options_BTN.setText(u'FBX导出选项')
        self.label.setText(u'输出路径')
        self.Path_BTN.setText(u'选择路径')
        self.Export_BTN.setText(u'FBX导出')

class MF_FBXEXP_UI(QWidget,Ui_Form):
    def __init__(self):
        super(MF_FBXEXP_UI,self).__init__(MaxPlus.GetQMaxWindow())

        self.setupUi(self)
        self.Options_BTN.clicked.connect(self.openOptions)
        self.Path_BTN.clicked.connect(self.selectPath)
        self.Export_BTN.clicked.connect(self.exportFBX)
        
        # NOTE 防止窗口多开
        for child in MaxPlus.GetQMaxWindow().children():
            if 'MF_FBXEXP_UI' in str(type(child)):
                child.close()

        self.show()

        # NOTE 读取路径
        self.initPath()

    def initPath(self):

        if not os.path.exists(SCRIPT_PATH):
            return

        with open(SCRIPT_PATH,'r') as f:
            path = f.read()
        
        self.Path_LE.setText(path)

    def openOptions(self):
        rt.OpenFbxSetting()

    def selectPath(self):

        # NOTE 根据现有的路径打开路径选择
        directory = os.path.dirname(self.Path_LE.text())
        if not os.path.exists(directory):
            directory = ''

        output_path = QFileDialog.getExistingDirectory(self,dir=directory,caption=u'导出FBX文件目录')     
        
        # NOTE 如果关闭窗口或者取消
        if not output_path :
            return
        
        self.Path_LE.setText(output_path)

        with open(SCRIPT_PATH,'w') as f:
            f.write(output_path)

    def exportFBX(self):
        
        output_path = os.path.normpath(self.Path_LE.text())
        output_path = output_path.replace(\"\\\\\",\"/\")

        if output_path == '':
            QMessageBox.warning(self,u'警告',u'路径不能为空')
            return
        
        folder = os.path.dirname(output_path)
        if not os.path.exists(folder):
            QMessageBox.warning(self,u'警告',u'当前给定目录不存在，请重新选择路径')
            return

        # NOTE 无窗口批量导出FBX
        MaxPlus.Core.EvalMAXScript('''
        if selection.count != 0 then(
            sel_list = selection as array
            deselect sel_list
            for obj in sel_list do(
                select obj
                path_name = \"{0}/\" + obj.name + \".fbx\"
                exportFile path_name #noPrompt selectedOnly:True using:FBXEXP
            )
        ) else (
            file_name = getFilenameFile maxfilename
            path_name = \"{0}/\" + file_name + \".fbx\"
            exportFile path_name #noPrompt selectedOnly:False using:FBXEXP
        )
        '''.format(output_path))


if __name__ == '__main__':
    FBXEXP = MF_FBXEXP_UI()
        
    "
)

----------------------------
-- NOTE 创建面板
----------------------------

mainMenuBar = menuMan.getMainMenuBar()
ori_OP_menu = menuMan.findMenu("OP")
if (not ori_OP_menu == undefined) do
(
	menuMan.unRegisterMenu ori_OP_menu
)
subMenu = menuMan.createMenu "OP"
FBXExportItem = menuMan.createActionItem "OP" "OP FBX Export"
subMenu.addItem FBXExportItem -1
subMenuItem = menuMan.createSubMenuItem "FBX批量导出工具" subMenu
subMenuIndex = mainMenuBar.numItems() - 1
mainMenuBar.addItem subMenuItem subMenuIndex
menuMan.updateMenuBar()