import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.2
import Setting 1.0

Rectangle {
    id:root
    color: "#55000000"
    property string pathName: Setting.getDownloadPath()
    property bool isSave: false
//    signal save()
//    signal saveDownloadPath()
    signal saveMulticastIP()
    signal saveHostPort()
    signal openFileDialog()
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    function saveSet() {
        if(root.isSave) {
            if(Setting.getDownloadPath() !== root.pathName) {
                Setting.setDownloadPath(root.pathName)
                pathName = Setting.getDownloadPath()
            }
            if(Setting.getMulticastIP() !== addrText.text) {
                Setting.setMulticastIP(addrText.text)
                root.saveMulticastIP()
            }
            if(Setting.getHostPort() !== Number(portText.text)) {
                Setting.setHostPort(portText.text)
                root.saveHostPort()
            }
            Setting.sync()
        }
        root.isSave = false
    }
    function inputCheck() {
        if(addrText.text === Setting.getMulticastIP() && Number(portText.text) === Setting.getHostPort() && root.pathName === Setting.getDownloadPath())
            return isSave = false
        if(portText.text === "")
            return isSave = false
        if(addrText.text.split(".").length == 4 && addrText.text.split(".")[3] !== "")
            return isSave = true
        return isSave = false
    }

    FileDialog {
        id: fileDialog
        title: qsTr("选择保存目录")
        selectMultiple: false
        selectFolder: true
        onAccepted: {
            if(Qt.platform.os === "windows")
                root.pathName = fileDialog.fileUrl.toString().substring(8)
            else root.pathName = fileDialog.fileUrl.toString().substring(7)
            root.inputCheck()
        }
      }

    Rectangle {
        width: parent.width - 40
        height: parent.height / 1.2
        anchors.centerIn: parent
        clip: true
        radius: 10

        Column {
            width: parent.width - 40
            height: parent.height - bottom.height
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Rectangle {
                width: parent.width
                height: 30
                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 22
                    font.bold: true
                    text: qsTr("Setting")
                }
            }
            Rectangle {
                id:pathRect
                width: parent.width
                height: 80
                color: "#f0f0f0"
                radius: 10

                Rectangle {
                    width: parent.width - 20
                    height: parent.height
                    anchors.centerIn: parent
                    color: "transparent"
                    Text {
                        width: parent.width
                        anchors.top: parent.top
                        anchors.topMargin: 15
                        font.bold: true
                        font.pixelSize: 20
                        elide:Text.ElideMiddle
                        color: "#1c1c1e"
                        text: qsTr("下载目录 ") + "(" + pathName.split("/")[pathName.split("/").length - 1] + ")"
                    }
                    Text {
                        width: parent.width
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 15
                        font.pixelSize: 17
                        color: "#636366"
                        elide:Text.ElideMiddle
                        text: root.pathName
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {pathRect.color = "#e0e0e0"}
                        onExited: {pathRect.color =  "#f0f0f0"}
                        onPressed: {pathRect.color =  "#d0d0d0"}
                        onReleased: {pathRect.color =  "#e0e0e0"}
                        onClicked: {
//                            root.openFileDialog()
                            if(Qt.platform.os === "android") {
                                root.openFileDialog()
                            } else {
                                fileDialog.open()
                            }
                        }
                    }

                }
            }


            Rectangle {
                width: parent.width
                height: 80
                color: "#f0f0f0"
                radius: 10
                Rectangle {
                    width: parent.width - 20
                    height: parent.height
                    anchors.centerIn: parent
                    color: "transparent"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.bold: true
                        font.pixelSize: 20
                        color: "#1c1c1e"
                        text: qsTr("端口")
                    }
                    TextField {      // 输入端口
                        id:portText
                        validator: RegExpValidator{regExp: /^([0-9]|[1-9]\d{1,3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$/}
                        width: parent.width / 3
                        height: parent.height - 30
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        horizontalAlignment: Text.AlignHCenter
                        color: "#1c1c1e"
                        text: Setting.getHostPort()
                        selectByMouse: true
                        selectionColor: "#57C3C2"
                        selectedTextColor: "#fff"
                        hoverEnabled: true
                        font.pixelSize: 24
                        background: Rectangle {
                            radius: 8
                        }
                        onTextEdited: {
                            root.inputCheck()
                        }
                    }
                }
            }
            Rectangle {
                width: parent.width
                height: 80
                color: "#f0f0f0"
                radius: 10
                Rectangle {
                    width: parent.width - 20
                    height: parent.height
                    anchors.centerIn: parent
                    color: "transparent"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.bold: true
                        font.pixelSize: 20
                        color: "#1c1c1e"
                        text: qsTr("多播地址")
                    }
                    TextField {     // 输入地址
                        id:addrText
                        validator: RegExpValidator{regExp: /^(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])$/}
                        width: parent.width / 2
                        height: parent.height - 30
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        horizontalAlignment: Text.AlignHCenter
                        text: Setting.getMulticastIP()
                        color: "#1c1c1e"
                        selectByMouse: true
                        selectionColor: "#57C3C2"
                        selectedTextColor: "#fff"
                        hoverEnabled: true
                        font.pixelSize: 24
                        background: Rectangle {
                            radius: 8
                        }
                        onTextEdited: {
                            root.inputCheck()
                        }
                    }
                }
            }
        }

        Rectangle {
            id:bottom
            width: parent.width
            height: 80
            anchors.bottom: parent.bottom
            color: "transparent"
            Button {
                id: button
                width: parent.width / 2
                height: 50
                anchors.centerIn: parent
                background: Rectangle {
                    radius: 5
                    color: button.pressed ? (isSave ? "#401ec337" : "#40f58b00") :
                                            (button.hovered ? (isSave ? "#291ec337" : "#29f58b00") :
                                                              (isSave ? "#201ec337" : "#20f58b00"))
                }
                onClicked: {
                    root.visible = !visible
                    root.saveSet()
                }
                Text {
                    anchors.centerIn: parent
                    text: isSave ? qsTr("保存") : qsTr("取消")
                    font.pixelSize: 22
                    font.bold: true
                    color: isSave ? "#1ec337" : "#f58b00"
                }
            }
        }


    }


}
