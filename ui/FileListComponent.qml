import QtQuick 2.9
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.0
import MFileInfo 1.0

Rectangle {
    id:root
    color: "transparent"
    property real selectSum: 0
    property real dataSize: 0
    property bool isAndroid: Qt.platform.os === "android"
    property ListModel listmodel

    signal clicked()

    function addFile(path) {
        if(!MFileInfo.setFile(path))
            return ;
        listmodel.append({"checkedState" : false,
                         "fileName" : MFileInfo.getFileName(),
                         "filePath" : MFileInfo.getFilePath(),
                         "fileSize" : MFileInfo.getFileSize() })
    }

    ListComponent {
        id:listComp
        anchors.fill: parent
        listModel: root.listmodel
        spacing: 10
        centreText: "Size: " + MFileInfo.fileSizeFormat(dataSize)
        delegate: CheckFileItem {
            id:fileItem
            width: parent.width
            height: 80
            name: fileName
            path: filePath
            size: MFileInfo.fileSizeFormat(fileSize)
            checked: checkedState
            onClicked: {
                checkedState = !checkedState
                if(checkedState) {
                    listComp.selectSum ++
                    dataSize += fileSize
                } else {
                    listComp.selectSum --
                    dataSize -= fileSize
                }
                selectSum = listComp.selectSum
            }
        }
        onRemove: {
            MFileInfo.remove(root.listmodel.get(index).fileName)
        }

        onSelectButClicked: {
            root.selectSum = listComp.selectSum
        }
        onDeleteButClicked: {
            dataSize = 0
            root.selectSum = 0
        }
        onSelect: {
            dataSize += listmodel.get(index).fileSize
        }
        onDeselect: {
            dataSize -= listmodel.get(index).fileSize
        }
    }
    // 拖入添加文件
    DropArea {
        anchors.fill: parent
        visible: !root.isAndroid
        onDropped: {
            if(!drop.hasUrls)
                return
            for(var i in drop.urls) {
                addFile(drop.urls[i].substring(8))
            }
        }
    }
    // 点击添加文件

    Rectangle {
        width: parent.width - 40
        height: parent.height / 2
        border.width: 1
        border.color: "#cdcdcd"
        anchors.centerIn: parent
        visible: listmodel.count === 0
        radius: 10
        Row {
            anchors.centerIn: parent
            spacing: 10
            Image {
                id:image
                width: 50
                height: 50
                mipmap: true
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/addFile.png"
            }
            Text {
                anchors.verticalCenter: image.verticalCenter
                font.bold: true
                text: root.isAndroid ? qsTr("点击添加文件") : qsTr("拖入添加文件")
                font.pixelSize: 26
                color: "#cdcdcd"
            }
        }
        MouseArea {
            anchors.fill: parent
            visible: root.isAndroid && root.listmodel.count === 0
            onClicked: {
                root.clicked()
            }
        }
    }
}
