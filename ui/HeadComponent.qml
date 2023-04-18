import QtQuick 2.9
import QtQuick.Controls 2.5
import Setting 1.0

Rectangle {
    id:root
    color: "transparent"
    property bool isBind: true
    property real upSum: 0
    property real downSum: 0
    property string hostIP: ""


    signal downButClicked()
    signal upButClicked()
    signal bind(var ip)
    ListModel{id:hostList}


    Button {
        id:downBut
        width: parent.width / 6
        height: parent.height - 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        Image {
            mipmap: true
            width: 25
            height: 25
            anchors.centerIn: parent
            source: "qrc:/download.png"
        }
        background: Rectangle {
            color: downBut.pressed ? "#ccc" : downBut.hovered ? "#eee" : "transparent"
            radius: 25
        }
        Label {
            visible: downSum !== 0
            anchors.right: parent.right
            anchors.rightMargin: 10
            text: downSum
            font.pixelSize: 17
            color: "red"
            font.bold: true
        }
        onClicked: {
            downButClicked()
        }

    }
    ComboBox {
        id:comboBox
        width: parent.width / 2
        height: parent.height - 20
        anchors.centerIn: parent
        indicator: Canvas{} // 隐藏上下箭头
        displayText: root.hostIP
        model: hostList

        delegate: ItemDelegate {
            width: comboBox.width
            height: comboBox.height
            contentItem: Text {
                text: hostIP
                color: "#1ec337"
                font.pixelSize: 22
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
            background: Rectangle {
                color: parent.pressed ? "#551ec337" : parent.hovered ? "#331ec337" : "transparent"
            }
        }
        popup: Popup {
            width: comboBox.width
            y:comboBox.height
            height: comboBox.height * (comboBox.count > 4 ? 4 : comboBox.count)
            padding:0
            background: Rectangle {}
            contentItem: ListView {
                clip: true
                width: parent.width
                height: comboBox.height
                model: comboBox.popup.visible ? comboBox.delegateModel : null
            }
            Rectangle {
                anchors.fill: parent
                color: "#201ec337"
            }
        }
        background: Rectangle {
            radius: 5
            color: !isBind ? "#20ff3126" : "#201ec337"
        }
        contentItem: Text {
            text: parent.displayText
            color: !isBind ? "#ff3126" : "#1ec337"
            font.pixelSize: 24
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
        onActivated: {  // 重新绑定IP地址
            Setting.setHostIP(comboBox.currentText)
            root.bind(comboBox.currentText)
            root.hostIP = comboBox.currentText
        }
        MouseArea {   // 刷新IP地址列表
            anchors.fill: parent
            onClicked: {
                comboBox.popup.visible = !comboBox.popup.visible
                if(comboBox.popup.visible === false)
                    return
                let list = Setting.getAddressList();
                hostList.clear()
                for(let i in list)
                    hostList.append({"hostIP" : list[i]})
            }
        }


    }

    Button {
        id:upBut
        width: parent.width / 6
        height: parent.height - 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        Image {
            mipmap: true
            width: 25
            height: 25
            anchors.centerIn: parent
            source: "qrc:/upload.png"
        }

        background: Rectangle {
            color: upBut.pressed ? "#ccc" : upBut.hovered ? "#eee" : "transparent"
            radius: 25
        }
        Label {
            visible: upSum !== 0
            anchors.right: parent.right
            anchors.rightMargin: 10
            text: upSum
            font.pixelSize: 17
            color: "red"

            font.bold: true
        }
        onClicked: {
            upButClicked()
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
