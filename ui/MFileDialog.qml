import QtQuick 2.9
import QtQuick.Controls 2.5
import MFileInfo 1.0

Rectangle {
    id:root
    color: "#55000000"
    visible: false
    property bool isSelectDir: false
    property bool isSelect: selectSum !== 0
    property real fileSum: 0
    property real selectSum: 0
    property string path: ""
    property string title: ""
    // 添加文件时调用信号
    signal addFiles(var index)
    signal selectDir()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    ListModel {id:fileList}
    // 添加多选文件
    function addMultipleFile() {
        for(var i=0;i<fileList.count;i++) {
            var it = fileList.get(i)
            if(it.checkedState) {
                root.addFiles(it.id)
                selectSum--
            }
            if(selectSum === 0) {
                console.log("添加完成")
                return ;
            }
        }
    }

    // 刷新文件列表
    function refreshList() {
        root.fileSum = MFileInfo.getEntryCount()
        root.path = MFileInfo.getAbsolutePath()
        listView.positionViewAtBeginning()
        fileList.clear();
        for(var i=0;i<root.fileSum;i++) {
            addItem(i)
        }
    }
    // 开启文件选择
    function open() {
        isSelectDir = false
        root.visible = true
        MFileInfo.setSelectDir(false)
        refreshList()
    }
    // 开启目录选择
    function openDir() {
        isSelectDir = true
        root.visible = true
        MFileInfo.setSelectDir(true)
        refreshList()
    }

    // 设置打开路径
    function setPath(path) {
        selectSum = 0
        MFileInfo.setPath(path)
        refreshList()
    }
    // 添加文件项
    function addItem(i) {
        var size = MFileInfo.isFile(i) ? MFileInfo.fileSizeFormat(MFileInfo.getFileSize(i)) :
                                         MFileInfo.getDirCount(i) + "个项目"
        fileList.append({
                            "id":i,
                            "checkedState": false,
//                            "filePath": MFileInfo.getFilePath(i),
                            "fileName": MFileInfo.getName(i),
                            "fileSize": size,
                            "fileDate": MFileInfo.getDate(i),
                            "isFile"  : MFileInfo.isFile(i),
                            "isDir"   : MFileInfo.isDir(i)
                        })
    }

    Rectangle {
        width: parent.width - 40
        height: parent.height / 1.2
        anchors.centerIn: parent
        radius: 10
        Column {
            width: parent.width - 40
            height: parent.height
            anchors.centerIn: parent
            Rectangle {
                id:textRect
                width: parent.width
                height: 60
                color: "transparent"
                Column {
                    width: parent.width - 20
                    anchors.centerIn: parent
                    spacing: 5
                    Text {
                        width: parent.width
                        font.pixelSize: 20
                        font.bold: true
                        elide: Text.ElideMiddle
                        horizontalAlignment: Text.AlignHCenter
                        color: "#1c1c1e"
                        text: root.title
                    }
                    Text {
                        width: parent.width
                        font.pixelSize: 17
                        font.bold: true
                        color: "#1c1c1e"
                        elide: Text.ElideMiddle
                        text: root.path
                    }
                }
            }
            ListView {
                id:listView
                width: parent.width
                height: parent.height - textRect.height - bottomBut.height
                clip: true
                spacing: 10
                model: fileList
                delegate: FileItem {
                    id:fileItem
                    width: parent.width
                    height: 60
                    checkable: root.selectSum !== 0 && isFile
                    checked: checkedState
                    name: fileName
                    date: fileDate
                    size: fileSize
                    isFileDir: isDir
                    // 选择文件或切换目录
                    onClicked: {
                        if(isDir && selectSum === 0) // 切换目录
                            setPath(MFileInfo.getAbsoluteFilePath(id))
                        else if(isFile && root.isSelect){  // 多选
                            checkedState = !checkedState
                            if(checkedState) {
                                selectSum ++
                            } else {
                                selectSum --
                            }
                        } else if(isFile) {  // 单选
                            addFiles(id)
                            root.visible = false
                        }

                    }
                    // 长按触发多选
                    onPressAndHold: {
                        if(root.isSelect) return ;
                        if(isFile) {
                            selectSum = 1
                            checkedState = true
                        }
                    }

                }
            }
            Rectangle {
                id:bottomBut
                width: parent.width
                height: 80
                Row {
                    width: parent.width
                    anchors.centerIn: parent
                    Rectangle {
                        width: parent.width / 3
                        height: 50
                        Text {
                            anchors.centerIn: parent
                            font.pixelSize: 16
                            font.bold: true
                            color: "#1ec337"
                            text: "SE:" + selectSum + "/" + fileSum
                        }
                    }

                    Button {
                        id:button
                        width: parent.width / 3
                        height: 50
                        Text {
                            anchors.centerIn: parent
                            text: root.isSelect || root.isSelectDir ? qsTr("确定") : qsTr("取消")
                            font.pixelSize: 22
                            font.bold: true
                            color: root.isSelect || root.isSelectDir ? "#1ec337" : "#f58b00"
                        }
                        background: Rectangle {
                            radius: 5
                            color :  button.pressed ? (root.isSelect || root.isSelectDir ? "#401ec337" : "#40f58b00") :
                                                       (button.hovered ? (root.isSelect || root.isSelectDir ? "#291ec337" : "#29f58b00") : (root.isSelect || root.isSelectDir ? "#201ec337" : "#20f58b00"))
                        }
                        onClicked: {
                            root.visible = false
                            if(isSelectDir) {
                                root.selectDir()
                            }
                            else if(root.isSelect) {
                                root.addMultipleFile()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width / 3
                        height: parent.height
                        Button {
                            id:backBut
                            width: 50
                            height: 50
                            anchors.centerIn: parent
                            enabled: !isSelect
                            Image {
                                mipmap: true
                                width: 25
                                height: 25
                                source: "qrc:/back.png"
                                anchors.centerIn: parent
                            }
                            onClicked: {
                                if(MFileInfo.cdUp()) {
                                    refreshList()
                                }
                            }
                            background: Rectangle {
                                color: backBut.pressed ? "#ccc" : backBut.hovered ? "#eee" : "transparent"
                                radius: 25

                            }
                        }
                    }

                }
            }
        }
    }
}
