import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import UploadFiles 1.0
import DownloadFiles 1.0
import UdpServer 1.0
import MFileInfo 1.0

Window {
    id: root
    visible: true
    width: 480
    height: 700
    title: qsTr("FastTransfer")
    minimumWidth: 480
    minimumHeight: 700

    property real transferSum: 0   // 正在上传的数量
    property real upSuccessSum: 0  // 上传成功的数量
    property real upFailSum: 0     // 上传失败的数量
    property real downSuccessSum: 0  // 下载成功的数量
    property real downFailSum: 0     // 下失败的数量

    ListModel {id:fileList}
    ListModel {id:uploadList}
    ListModel {id:downloadList}

    property bool butState: false

    function reBind() {
        if(DownloadFiles.startServer())
            UdpServer.bind();
    }

    function hostName(ip) {
        if(ip === "") return ""
        return "Host:#" + ip.split(".")[3]
    }

    function addUploadFile(ip,port,path,name,size) {
        let id = uploadList.count
        UploadFiles.addTask(id,path + "/" + name,ip,port)
        uploadList.insert(id - upSuccessSum - upFailSum,{
                              "id": id,
                              "checkedState": false,
                              "progressValue": -1,
                              "fileName": name,
                              "fileSize": size,
                              "hostName" : hostName(ip) + "(" + ip + ":" + port + ")",
                              "transferSpeed" : "0MB/S",
                              "accomplishState" : false,
                              "transferState" : false
                          })
    }
    function addDownloadFile(id,name,size,ip,port) {
        downloadList.insert(0,{
                              "id": id,
                              "checkedState": false,
                              "progressValue": 0,
                              "fileName": name,
                              "fileSize": MFileInfo.fileSizeFormat(size),
                              "hostName" : hostName(ip) + "(" + ip + ":" + port + ")",
                              "transferSpeed" : "0MB/S",
                              "accomplishState" : false,
                              "transferState" : true
                          })
    }

    function findIndex(list,id) {
        for(let i=0;i<list.count;i++) {
            if(list.get(i).id === id)
                return i
        }
        return -1
    }
    // 连接上传信号
    Connections {
        target: UploadFiles
        function onStartUpTask(id,name,size,ip,port) {
            transferSum++;
            var i = findIndex(uploadList,id)
            uploadList.setProperty(i,"checkedState",false)
            uploadList.setProperty(i,"transferState",true)
            uploadList.setProperty(i,"progressValue",0)
            uploadList.setProperty(i,"fileName",name)
            uploadList.setProperty(i,"fileSize",MFileInfo.fileSizeFormat(size))
        }
        function onEndUpTask(id,state) {
            transferSum--;
            var i = findIndex(uploadList,id)
            uploadList.setProperty(i,"accomplishState",state)
            uploadList.setProperty(i,"transferState",false)
            if(state) {
                uploadList.move(i,uploadList.count - root.upFailSum - 1,1)
                upSuccessSum ++
            } else {
                uploadList.move(i,uploadList.count - 1,1)
                upFailSum ++
            }
        }
        function onUpProgressValue(id,value) {
            var i = findIndex(uploadList,id)
            uploadList.setProperty(i,"progressValue",value)

        }
        function onUpSpeed(id,speed) {
            var i = findIndex(uploadList,id)
            uploadList.setProperty(i,"transferSpeed",MFileInfo.fileSizeFormat(speed) + "/S")
        }
    }
    // 连接下载信号
    Connections {
        target: DownloadFiles
        function onStartDownTask(id,name,size,ip,port) {
            addDownloadFile(id,name,size,ip,port)
        }
        function onEndDownTask(id,state) {
            var i = findIndex(downloadList,id)
            if(i < 0) return;
            downloadList.setProperty(i,"id",-1)
            downloadList.setProperty(i,"accomplishState",state)
            downloadList.setProperty(i,"transferState",false)
            if(state) {
                downloadList.move(i,downloadList.count - root.downFailSum - 1,1)
                root.downSuccessSum++
            } else {
                downloadList.move(i,downloadList.count - 1,1)
                root.downFailSum++
            }
        }
        function onDownProgressValue(id,value) {
            var i = findIndex(downloadList,id)
            downloadList.setProperty(i,"progressValue",value)    
        }
        function onDownSpeed(id,speed) {
            var i = findIndex(downloadList,id)
            downloadList.setProperty(i,"transferSpeed",MFileInfo.fileSizeFormat(speed) + "/S")
        }

    }

    Connections {
        target: UdpServer
        function onAvailableHost(ip,port) {
            scanHostComp.addHost(hostName(ip),ip,port)
        }
    }

    Connections {
        target: UdpServer
        function onBindStateSig(state)
        {
            headComp.isBind = state
        }
    }
    // android 文件选择框
    MFileDialog {
        id:mfileDialog
        width: parent.width
        height: parent.height - headComp.height
        y: headComp.height
        z:1
        onAddFiles: { // 添加已选择的文件
            fileListComp.addFile(MFileInfo.getAbsoluteFilePath(index))
        }
        onSelectDir: { // 选择的下载路径
            settingPage.pathName = MFileInfo.getAbsolutePath()
            settingPage.inputCheck()
        }
    }

    Rectangle {
        id:bottomRect
        width: parent.width
        height: bottomComp.height
        y: parent.height - height
        color: "#f8f8f8"
    }

    Column {
        width: parent.width - 40
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        HeadComponent {
            id:headComp
            width: parent.width
            height: 60
            upSum: uploadList.count
            downSum: downloadList.count
            hostIP: DownloadFiles.getServerIP()
            onUpButClicked: {
                uploadPage.visible = true
            }
            onDownButClicked: {
                downloadPage.visible = true
            }
            onBind: {
                root.reBind()
            }
        }
        Column {
            width: parent.width
            height: parent.height - headComp.height
            FileListComponent {
                id:fileListComp
                width: parent.width
                height: parent.height - bottomComp.height
                listmodel: fileList
                onClicked: {
                    mfileDialog.title = "选择文件"
                    mfileDialog.open()
                }
            }
            BottomComponent {
                id: bottomComp
                width: parent.width
                height: 100
                isSend: fileListComp.selectSum !== 0
                hostName: root.hostName(headComp.hostIP)
                onAddFile: {
                    fileListComp.addFile(path)
                }
                onSelectFile: {
                    mfileDialog.title = "选择文件"
                    mfileDialog.open()
                }
                onSendFile: {
                    scanHostComp.scanHost()
                    scanHostComp.visible = true
                }
                onSettingButClicked: {
                    settingPage.visible = true
                }

            }
        }
    }

    SettingPage {
        id:settingPage
        width: parent.width
        height: parent.height - headComp.height
        visible: false
        y: headComp.height
        onSaveMulticastIP: {
            UdpServer.joinMulticastGroupSig()
        }
        onSaveHostPort: {
            root.reBind()
        }
        onOpenFileDialog: {
            mfileDialog.title = "选择目录"
            mfileDialog.openDir()
        }
    }

    ScanHostComponent {
        id:scanHostComp
        width: parent.width
        height: parent.height - headComp.height
        visible: false
        y: headComp.height
        clip: true
        onScanButClicked: {
            UdpServer.scanHost()
        }
        onSendFile: {
            for(let i=0;i<fileList.count;i++) {
                let it = fileList.get(i)
                if(it.checkedState) {
                    addUploadFile(ip,port,it.filePath,it.fileName,MFileInfo.fileSizeFormat(it.fileSize))
                }
            }
            uploadPage.visible = true
        }
    }

    UploadPage {
        id:uploadPage
        visible: false
        anchors.fill: parent
        listModel: uploadList
        centreText: "AC:" + root.upSuccessSum + " ER:" + root.upFailSum
        z:3
        onRemove: { // 删除队列内任务
            var sum = uploadList.count - upSuccessSum - upFailSum
            if(index < sum) {
                var s = UploadFiles.remove(index - transferSum)
//                console.log("onRemove: ",s," ",index - transferSum)
                return
            }
            var it = uploadList.get(index)
            if(it.accomplishState) {
                root.upSuccessSum--
            } else {
                root.upFailSum--
            }
        }
        onDeleteClicked: {  // 删除正在上传的任务
            var id = uploadList.get(index).id
            UploadFiles.deleteTask(id)
        }
    }
    DownloadPage {
        id:downloadPage
        visible: false
        anchors.fill: parent
        listModel: downloadList
        centreText: "AC:" + root.downSuccessSum + " ER:" + root.downFailSum
        z:3
        onRemove: { // 删除已下载任务
            var it = downloadList.get(index)
            if(it.accomplishState) {
                root.downSuccessSum --
            } else {
                root.downFailSum--
            }
        }
        onDeleteClicked: {  // 删除正在进行的下载任务
            var id = downloadList.get(index).id
            DownloadFiles.deleteTask(id)
        }
    }

}
