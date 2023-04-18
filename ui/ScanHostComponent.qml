import QtQuick 2.9
import QtQuick.Controls 2.5

Rectangle {
    id:root
    color: "#55000000"
    property bool isShow: false
    property real selectSum: 0
    property bool isSend: selectSum !== 0

    signal scanButClicked()
    signal sendFile(var ip,var port)

    ListModel{id:hostList}

    function scanHost() {
        hostList.clear() // 删除所有主机
        root.selectSum = 0
        root.scanButClicked()
    }

    function addHost(name,ip,port) {
        hostList.append({
                            "checkedState" : false,
                            "hostName": name,
                            "hostIP" : ip,
                            "hostPort" : port
                        })
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Rectangle {
        width: parent.width - 40
        height: parent.height / 1.2
        anchors.centerIn: parent
        clip: true
        radius: 10

        Image {  // 空提示图片
            visible: hostList.count === 0
            anchors.centerIn: parent
            width: 100
            height: 100
            source: "qrc:/nullHost.png"
        }

        Column {
            width: parent.width - 40
            height: parent.height
            anchors.centerIn: parent
            clip: true
            Rectangle {
                id:headRect
                width: parent.width
                height: 50
                Text {     // 主机数量
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width / 1.5
                    font.pixelSize: 18
                    font.bold: true
                    elide:Text.ElideRight
                    text: "Selete: " + selectSum + "/" + hostList.count

                }
                Row {
                    height: parent.height
                    anchors.right: parent.right
                    spacing: 10
                    Button {    // 扫描按钮
                        id:scanBut
                        anchors.verticalCenter: parent.verticalCenter
                        width: 50
                        height: 30
                        font.bold: true

                        Image {
                            mipmap: true
                            width: 20
                            height: 18
                            anchors.centerIn: parent
                             source: "qrc:/scan.png"
                        }

                        background: Rectangle {
                            color: scanBut.pressed ? "#4f1ec337" : scanBut.hovered ? "#331ec337" : "#201ec337"
                            radius: 5
                        }
                        onClicked: {
                            root.scanHost()
                        }
                    }

                    Button {    // 选择按钮
                        id:button
                        anchors.verticalCenter: parent.verticalCenter
                        width: 50
                        height: 30
                        font.bold: true
                        font.pixelSize: 15
                        enabled: hostList.count !== 0
                        text: root.selectSum !== 0 ? qsTr("取消") : qsTr("全选")
                        background: Rectangle {
                            color: !button.enabled ? "#f0f0f0" : button.pressed ? "#b0b0b0" : button.hovered ? "#d0d0d0" : "#dfdfdf"
                            radius: 5
                        }
                        onClicked: {
                            var i,it
                            if(root.selectSum !== 0) { // 取消已选择的项
                                for(i = 0;i < hostList.count;i++) {
                                    it = hostList.get(i)
                                    if(it.checkedState === false)
                                        continue
                                    it.checkedState = false
                                    selectSum--
                                }
                            } else {
                                for(i = 0;i < hostList.count;i++) { // 全选
                                    it = hostList.get(i)
                                    it.checkedState = true
                                    selectSum++
                                }
                            }
                        }


                    }

                }
            }
            // 中间列表
            ListView {
                id:listView
                clip: true
                width: parent.width
                height: parent.height - bottomBut.height - headRect.height
                spacing: 10
                model: hostList
                delegate: CheckHostItem {
                    width: parent.width
                    height: 70
                    name: hostName
                    ip: hostIP
                    port: hostPort
                    checked: checkedState
                    onClicked: {
                        checkedState = !checkedState
                        if(checkedState) {
                            selectSum ++
                        } else {
                            selectSum --
                        }
                    }
                }

                displaced: Transition {
                    SmoothedAnimation {
                        property: "y"
                        duration: 300
                    }
                }
                remove: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 150
                    }
                }

            }
            // 底部按钮
            Rectangle {
                id:bottomBut
                width: parent.width
                height: 80
                Button {
                    id:sendBut
                    width: parent.width / 2
                    height: 50
                    anchors.centerIn: parent
                    background: Rectangle {
                        radius: 5
                        color :  sendBut.pressed ? (isSend ? "#401ec337" : "#40f58b00") :
                                                   (sendBut.hovered ? (isSend ? "#291ec337" : "#29f58b00") : (isSend ? "#201ec337" : "#20f58b00"))
                    }
                    onClicked: {
                        root.visible = false
                        if(isSend) {
                            for(var i = 0;i<hostList.count;i++) {
                                var it = hostList.get(i)
                                if(it.checkedState) {
                                    root.sendFile(it.hostIP,it.hostPort)
                                    it.checkedState = false
                                }
                            }
                            selectSum = 0
                        }
                        hostList.clear()
                    }
                    Text {
                        anchors.centerIn: parent
                        text: isSend ? qsTr("确定") : qsTr("取消")
                        font.pixelSize: 22
                        font.bold: true
                        color: isSend ? "#1ec337" : "#f58b00"
                    }

                }
            }



        }

    }





}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
