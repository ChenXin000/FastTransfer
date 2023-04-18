import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.2

Rectangle {
    id: root
    color: "transparent"
    property string hostName: ""
    property bool isSend: false
    signal selectFile()
    signal addFile(var path)
    signal sendFile()
    signal settingButClicked()

    FileDialog {
        id: fileDialog
        title: qsTr("选择文件")
        folder: shortcuts.desktop
        selectMultiple: true
        onAccepted: {
            for(var i in fileDialog.fileUrls) {
                addFile(fileDialog.fileUrls[i].substring(8))
            }
        }
    }

    Button {
        id:butRect
        width: parent.width / 3
        height: parent.height - 40
        anchors.centerIn: parent
        background: Rectangle {
            radius: 5
            color :  butRect.pressed ? (isSend ? "#401ec337" : "#40f58b00") :
                                       (butRect.hovered ? (isSend ? "#291ec337" : "#29f58b00") : (isSend ? "#201ec337" : "#20f58b00"))
        }
        Row {
            anchors.centerIn: parent
            spacing: 5
            Image {
                id:image
                width: 30
                height: 30
                mipmap: true
                anchors.verticalCenter: parent.verticalCenter
                source: isSend ? "qrc:/sending.png" : "qrc:/addFile2.png"
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 20
                color: isSend ? "#1ec337" : "#f58b00"
                font.bold: true
                text: isSend ? qsTr("发送") : qsTr("添加")
            }
        }

        onClicked: {
            if(isSend) root.sendFile()
            else {
//                root.selectFile()
                if(Qt.platform.os === "android")
                    root.selectFile()
                else
                    fileDialog.open()

            }
        }

    }
    Rectangle {
        color: "transparent"
        width: parent.width / 3
        height: parent.height - 40
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        Button {
            id:setBut
            width: 50
            height: 50
            anchors.centerIn: parent
            Image {
                mipmap: true
                width: 30
                height: 30
                source: "qrc:/setting.png"
                anchors.centerIn: parent
            }
            background: Rectangle {
                color: setBut.pressed ? "#ccc" : setBut.hovered ? "#eee" : "transparent"
                radius: 25

            }
            onClicked: {
                root.settingButClicked()
            }
        }
    }

    Rectangle {
        color: "transparent"
        width: parent.width / 3
        height: parent.height - 40
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        Text {
            anchors.centerIn: parent
            font.pixelSize: 22
            font.bold: true
            text: root.hostName
            color: "#1ec337"
        }
    }


}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
