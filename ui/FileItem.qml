import QtQuick 2.9
import QtQuick.Controls 2.5

Button {
    id:root
    property string name: ""
    property string date: ""
    property string size: ""
    property bool isFileDir: false

    checkable: true
    Row {
        anchors.fill: parent
        Rectangle {
            width: parent.width / 6
            height: parent.height
            color: "transparent"
            Image {
                anchors.centerIn: parent
                width: 40
                height: 40
                source: isFileDir ? "qrc:/dir.png" : "qrc:/file.png"
            }
        }
        Rectangle {
            width: parent.width / 6 * 5
            height: parent.height
            color: "transparent"
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                Text {
                    id:name
                    width: parent.width - 10
                    font.pixelSize: 20
                    color: "#1c1c1e"
                    elide: Text.ElideMiddle
                    text: root.name
                }
                Row {
                    width: parent.width
                    Text {
                        id:date
                        width: parent.width / 3 * 2
                        font.pixelSize: 16
                        color: "#636366"
                        text: root.date
                    }
                    Text {
                        id:size
                        width: parent.width / 3
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 16
                        elide: Text.ElideRight
                        color: "#636366"
                        text: root.size
                    }
                }
            }
        }
    }


    background: Rectangle {
        color: root.checked ? "#8f007aff" : (root.pressed ? "#e0e0e0" : "#f0f0f0")
        radius: 6
    }
//color: "#007aff"
//    onPressAndHold: {
//        checked = true
//        console.log(11)
//    }

}
