import QtQuick 2.9
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.0

Rectangle {
    id:root
    property real selectSum: 0
    property string centreText: ""
    property ListModel listModel
    property Component delegate
    property real spacing: 0

    signal deleteButClicked()
    signal selectButClicked()
    signal select(var index)
    signal deselect(var index)
    signal remove(var index)

    Column {
        anchors.fill: parent
        spacing: 5
        Row {
            id: head
            width: parent.width
            height: 30
            spacing: 10
            Rectangle {
                width: parent.width / 4 * 3 - parent.spacing
                height: parent.height
                color: "transparent"
                Row {
                    anchors.fill: parent
                    spacing: 10
                    clip: true
                    Text {
                        width: parent.width / 2 - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 17
                        font.bold: true
                        elide:Text.ElideRight
                        text: "Select: " + root.selectSum + "/" + listModel.count
                        color: "#1c1c1e"
                    }
                    Text {
                        width: parent.width / 2 - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 17
                        font.bold: true
                        elide:Text.ElideRight
                        text: root.centreText
                        color: "#1c1c1e"
                    }
                }
            }
            Rectangle {
                width: parent.width / 4
                height: parent.height
                color: "transparent"
                Row {
                    anchors.centerIn: parent
                    spacing: 10
                    clip: true
                    Button {       // 删除按钮
                        id:deleteBut
                        enabled: root.selectSum !== 0
                        width: 50
                        height: 30
                        font.bold: true
                        Image {
                            width: 20
                            height: 20
                            mipmap: true
                            anchors.centerIn: parent
                            source: "qrc:/delete.png"
                            ColorOverlay {
                                anchors.fill: parent
                                source: parent
                                color: !deleteBut.enabled ? "#ff8888" : "#ff3126"
                            }
                        }
                        background: Rectangle {
                            color: !deleteBut.enabled ? "#15ff3126" : deleteBut.pressed ? "#4fff3126" : deleteBut.hovered ? "#33ff3126" : "#20ff3126"
                            radius: 5
                        }

                        onClicked: {
                            for(var i=0;i<listModel.count;++i) // 删除所有已选择项
                                if(listModel.get(i).checkedState === true) {
                                    root.remove(i)
                                    listModel.remove(i)
                                    i--
                                }
                            selectSum = 0
                            root.deleteButClicked()
                        }
                    }
                    Button {     // 取消全选按钮
                        id:selectBut
                        enabled: listModel.count !== 0
                        width: 50
                        height: 30
                        text: root.selectSum !== 0 ? qsTr("取消") : qsTr("全选")
                        font.bold: true
                        font.pixelSize: 15
                        background: Rectangle {
                            color: !selectBut.enabled ? "#f0f0f0" : selectBut.pressed ? "#b0b0b0" : selectBut.hovered ? "#d0d0d0" : "#dfdfdf"
                            radius: 5
                        }
                        onClicked: {
                            var i,it
                            if(root.selectSum !== 0) { // 取消已选择的项
                                for(i = 0;i < listModel.count;i++) {
                                    it = listModel.get(i)
                                    if(it.checkedState === false)
                                        continue
                                    it.checkedState = false
                                    selectSum--
                                    root.deselect(i)
                                }
                            } else {
                                for(i = 0;i < listModel.count;i++) { // 全选
                                    it = listModel.get(i)
                                    it.checkedState = true
                                    selectSum++
                                    root.select(i)
                                }
                            }
                            root.selectButClicked()
                        }
                    }
                }
            }
        }
        ListView {
            id:listView
            width: parent.width
            height: parent.height - head.height - parent.spacing
            spacing: root.spacing
            clip: true
            model: root.listModel
            delegate: root.delegate

            add: Transition {
                SmoothedAnimation {
                    property: "y"
                    duration: 200
                }

            }
//            displaced: Transition {
//                SequentialAnimation {
//                    SmoothedAnimation {
//                        property: "y"
//                        duration: 150
//                    }
//                }
//            }
            removeDisplaced: Transition{
                SmoothedAnimation {
                    property: "y"
                    duration: 200
                }
            }

//            remove: Transition {
//                SmoothedAnimation {
//                    property: "y"
//                    duration: 150
//                }
//                NumberAnimation {
//                    property: "opacity"
//                    from: 1
//                    to: 0
//                    duration: 150
//                }
//            }

        }

    }
}
