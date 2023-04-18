import QtQuick 2.9
import QtQuick.Controls 2.5

Rectangle {
    id:root
    radius: 10
    color: "#f0f0f0"

    property string name: ""
    property string path: ""
    property string size: ""
    property bool checked: false
    signal clicked()

    Rectangle {
        width: parent.width / 6
        height: parent.height
        anchors.left: parent.left
        clip: true
        color: "transparent"
        Image {
            width: 45
            height: 45
            mipmap: true
            anchors.centerIn: parent
            source: "qrc:/file.png"
        }
    }
    Rectangle {
        width: parent.width / 6 * 4
        height: parent.height
        anchors.centerIn: parent
        clip: true
        color: "transparent"
        Text {
            id:name
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 15
            elide:Text.ElideMiddle
            text: root.name
            font.bold: true
            font.pixelSize: 22
            color: "#1c1c1e"

        }
        Text {
            id:path
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            elide:Text.ElideRight
            text: root.path
            font.pixelSize: 18
            color: "#636366"
        }

    }
    Rectangle {
        width: parent.width / 6
        height: parent.height
        anchors.right: parent.right
        clip: true
        color: "transparent"
        CheckBox {
            id:checkBox
            anchors.centerIn: parent
            checked: root.checked
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            font.pixelSize:11
            font.bold: true
            color: "#636366"
            text: root.size
        }

    }
    MouseArea {
        anchors.fill:parent
        hoverEnabled: true
        onEntered: {root.color = "#e0e0e0"}
        onExited: {root.color =  "#f0f0f0"}
        onClicked: {
            root.clicked()
        }
    }

}
