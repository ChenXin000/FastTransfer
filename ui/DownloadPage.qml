import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Rectangle {
    id: root
    property ListModel listModel
    property string centreText: ""
    signal remove(var index)
    signal deleteClicked(var index)
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }
    Image {
        width: 100
        height: 100
        mipmap: true
        visible: listModel.count == 0
        anchors.centerIn: parent
        source: "qrc:/nullDown.png"
    }
    Column {
        width: parent.width - 40
        height: parent.height
        anchors.centerIn: parent
        Rectangle {
            id:headRect
            width: parent.width
            height: 60
            color: "transparent"
            Button {
                id:backBut
                width: 60
                height: 40
                Image {
                    mipmap: true
                    width: 25
                    height: 25
                    anchors.centerIn: parent
                    source: "qrc:/back.png"
                }
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    root.visible = false
                }
                background: Rectangle {
                    color: backBut.pressed ? "#ccc" : backBut.hovered ? "#eee" : "transparent"
                    radius: 25
                }

            }
            Text {
                anchors.centerIn: parent
                font.pixelSize: 22
                font.bold: true
                text: qsTr("Download")
            }
        }

        ListComponent {
            id:listComp
            width: parent.width
            height: parent.height - headRect.height
            listModel:root.listModel
            color: "transparent"
            centreText: root.centreText
            spacing: 10
            delegate: TransferItem {
                width: parent.width
                height: 80
                name: fileName
                size: fileSize
                host: hostName
                speed: transferSpeed
                isAccomplish : accomplishState
                isTransfer: transferState
                progress: progressValue
                checked: checkedState
                onClicked: {
                    checkedState = !checkedState
                    if(checkedState) {
                        listComp.selectSum ++
                    } else {
                        listComp.selectSum --
                    }
                }
                onDelButClicked: {
                    root.deleteClicked(index)
                }
            }
            onSelect: {
                var it = root.listModel.get(index);
                if(it.transferState)
                {
                    it.checkedState = false
                    listComp.selectSum--
                }
            }
            onRemove: {
                root.remove(index)
            }

        }
    }
}

