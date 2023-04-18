import QtQuick 2.9
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.0

Rectangle {
    id:root
    color: "#f0f0f0"
    radius: 10
    property string name: ""
    property string host: ""
    property string size: ""
    property string speed: ""
    property real progress: -1       // 传输进度
    property bool isAccomplish: false  // 是否传输完成
    property bool isTransfer: false // 是否传输
    property bool checked: false

    signal clicked()
    signal delButClicked()

    Rectangle {
        width: isAccomplish ? parent.width : parent.width * (progress < 0 ? 0 : progress)
        height: parent.height
        color: isTransfer || isAccomplish ? "#201ec337" : "#20ff3126"
        radius: 10
    }

    Row {
        anchors.fill: parent
        Rectangle {
            color: "transparent"
            width: parent.width / 6
            height: parent.height
            Image {
                width: 45
                height: 45
                visible: !valueText.visible
                anchors.centerIn: parent
                source: isAccomplish ? "qrc:/ok.png" : "qrc:/file.png"
            }
            Text {
                id:valueText
                visible: root.progress !== -1 && !isAccomplish  // 正在传输并且没有传输成功时显示红色进度(否者绿色)
                anchors.centerIn: parent
                font.pixelSize: 30
                font.bold: true
                color: isTransfer ? "#1ec337" : "#ff3126"
                text: parseInt(root.progress * 100)
            }
        }
        Rectangle {
            color: "transparent"
            width: parent.width / 6 * 4
            height: parent.height
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                spacing: 2
                Text {
                    id:fileName
                    width: parent.width
//                    anchors.top: parent.top
//                    anchors.topMargin: 8
                    font.pixelSize: 22
                    elide:Text.ElideRight
                    font.bold: true
                    color: "#1c1c1e"
                    text: root.name
                }
                Text {
                    width: parent.width
//                    anchors.top: fileName.bottom
                    font.pixelSize: 17
                    font.bold: true
                    elide:Text.ElideRight
                    color: "#007aff"
                    text: root.host
                }
                Row {
                    width: parent.width
//                    anchors.bottom: parent.bottom
//                    anchors.bottomMargin: 8
                    Text {
                        width: parent.width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 17
                        color: "#636366"
                        text: root.size
                    }
                    Text {
                        width: parent.width / 2
                        font.pixelSize: 17
                        color: "#636366"
                        text: root.speed
                    }
                }
            }

        }
        Rectangle {
            color: "transparent"
            width: parent.width / 6
            height: parent.height

            CheckBox {
                anchors.centerIn: parent
                visible: !isTransfer
                checked: root.checked
            }
            Button {
                id:deleteBut
                width: 45
                height: 45
                visible: isTransfer
                anchors.centerIn: parent
                Image {
                    width: 28
                    height: 28
                    anchors.centerIn: parent
                    source: "qrc:/delete.png"
                }
                background: Rectangle {
                    radius: 8
                    color: deleteBut.pressed ? "#4fff3126" : deleteBut.hovered ? "#33ff3126" : "#20ff3126"
                }
                onClicked: {
                    root.delButClicked()
                }
            }
        }
    }

    MouseArea {
        visible: !isTransfer
        anchors.fill:parent
        hoverEnabled: true
        onEntered: {root.color = "#e0e0e0"}
        onExited: {root.color =  "#f0f0f0"}
        onClicked: {
            root.clicked()
        }
    }



}
