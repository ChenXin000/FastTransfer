import QtQuick 2.9
import QtQuick.Controls 2.5

Rectangle {
    id:root
    color: "#f0f0f0"
    radius: 10
    property bool checked: false
    property string name: ""
    property string ip: ""
    property real port: 0
    signal clicked()
    Row {
        width: parent.width
        height: parent.height
        Rectangle {
            width: parent.width / 6
            height: parent.height
            color: "transparent"
            Image {
                width: 40
                height: 40
                anchors.centerIn: parent
                source: "qrc:/host.png"
            }
        }

        Column {
            width: parent.width / 6 * 4
            height: parent.height
            Rectangle {
                color: "transparent"
                width: parent.width
                height: parent.height / 2
                Text {   // 主机名
                    width: parent.width
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    font.pixelSize: 22
                    font.bold: true
                    elide:Text.ElideRight
                    color: "#1c1c1e"
                    text: root.name
                }
            }
            Rectangle {
                color: "transparent"
                width: parent.width
                height: parent.height / 2
                Text {     // 地址和端口
                    width: parent.width
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    font.pixelSize: 18
                    elide:Text.ElideRight
                    color: "#636366"
                    text: root.ip + ":" + root.port
                }
            }
        }

        Rectangle {
            width: parent.width / 6
            height: parent.height
            color: "transparent"
            CheckBox {
                id:checkBox
                anchors.centerIn: parent
                checked: root.checked
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {root.color = "#e0e0e0"}
        onExited: {root.color =  "#f0f0f0"}
        onClicked: {
            root.clicked()
        }
    }



}
