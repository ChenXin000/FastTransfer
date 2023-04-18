#include "downloadfiles.h"

DownloadTask::DownloadTask(qint32 id,BlockingQueue<qintptr> * queue) : downQueue(queue)
{
    setId(id);
}
DownloadTask::~DownloadTask()
{
    stopRun();
    downQueue->quit();
}
/*
 * 重写初始化socket
 * 从队列中取出socket描述符初始化socket
*/
void DownloadTask::initSocket()
{
    do {
        qintptr descriptor = downQueue->pop();
        if(isRun() && setSocketDescriptor(descriptor))
        {
            TaskBase::setFileInfo(new FileInfo);
            break;
        }
    }while(isRun());
    if(!sendFlag())
        socketClose();
    else
        isFirst = true;
}
/*
 * 重写文件初始化
 * 读取文件信息成功后调用
 * 打开文件并设置文件大小
*/
bool DownloadTask::initFile(FileInfo *fileInfo)
{
    downFileName = fileInfo->getFileName();
    downFileSize = fileInfo->getFileSize(); // 文件总大小
    QString path = Setting::getTempPath() + "/." + downFileName;
    QFile file(path);
    tCounter = counter = file.size();   // 设置已下载大小
    if(counter > downFileSize)
        tCounter = counter = 0;
    fileInfo->setInfo(downFileName,counter);
    return openFile(path,QIODevice::WriteOnly | QIODevice::Append);
}
/*
 * 重写读写数据的槽
*/
void DownloadTask::RWData()
{
    char * buffer = getRWBuffer();
    if(!readFileInfo() || !sendFileInfo())
        return ;
    if(isFirst)
    {
        isFirst = false;
        emit startTaskSignal(getId(),downFileName,downFileSize,getSocketAddress(),getSocketPort());
        timer.start();
        timer2.start();
    }
    while(!socketAtEnd())
    {
        qint64 Rlen = socketRead(buffer,getRWBufSize());
        if(Rlen < 0)
            break;
        qint64 Wlen = fileWrite(buffer,Rlen);
        if(Wlen < 0)
            break;
        counter += Wlen;
    }
    if(counter >= downFileSize)
    {
        socketClose();
        fileClose();
        setTransferState(counter == downFileSize);
        if(counter >= downFileSize)
        {
            QString tempPath = Setting::getTempPath() + "/." + downFileName;
            QString path = Setting::getDownloadPath() + "/" + downFileName;
            Setting::fileMove(tempPath,path);
        }
    }
    else if(isStopTask())
    {
        socketClose();
        fileRemove();
        setTransferState(counter == downFileSize);
    }
    if(timer.hasExpired(20))
    {
        float progress = ((float)counter / (float)downFileSize);  // 进度值
        emit progressValueSignal(getId(),progress);
        timer.start();
    }
    if(timer2.hasExpired(1000))
    {
        qint64 ms = timer2.restart();
        qint64 speed = (float)(counter - tCounter) / (float)ms * 1000;   // 速度
        tCounter = counter;
        emit speedSignal(getId(),speed);
    }

}

DownloadFiles::DownloadFiles()
{
    startServer();
    downQueue = new BlockingQueue<qintptr>;
    void (DownloadTask::*startTask)(qint32, QString, qint64, QString,quint16) = &DownloadTask::startTaskSignal;
    void (DownloadTask::*endTask)(qint32, bool) = &DownloadTask::endTaskSignal;
    void (DownloadTask::*progressValue)(qint32, float) = &DownloadTask::progressValueSignal;
    void (DownloadTask::*speed)(qint32, qint64) = &DownloadTask::speedSignal;
    for(int i=0;i<DOWNLOAD_THREAD_SUM;i++)
    {
        threadPool[i] = new DownloadTask(i,downQueue);
        connect(threadPool[i],startTask,this,&DownloadFiles::startDownTask);
        connect(threadPool[i],endTask,this,&DownloadFiles::endDownTask);
        connect(threadPool[i],progressValue,this,&DownloadFiles::downProgressValue);
        connect(threadPool[i],speed,this,&DownloadFiles::downSpeed);
    }
}

DownloadFiles::~DownloadFiles()
{
    for(int i=0;i<DOWNLOAD_THREAD_SUM;i++)
        threadPool[i]->deleteLater();
    delete downQueue;
}

DownloadFiles *DownloadFiles::getInstance()
{
    return new DownloadFiles;
}

bool DownloadFiles::startServer()
{
    if(isListening())
        close();
    return listen(HostInfo::getHostIP(),HostInfo::getHostPort());
}

void DownloadFiles::stopServer()
{
    close();
}

QString DownloadFiles::getServerIP()
{
    return serverAddress().toString();
}

quint16 DownloadFiles::getServerPort()
{
    return serverPort();
}

void DownloadFiles::deleteTask(qint32 id)
{
    for(int i=0;i<DOWNLOAD_THREAD_SUM;i++)
    {
        if(threadPool[i]->getId() == id)
            threadPool[i]->stopTask();
    }
}

bool DownloadFiles::addTask(qintptr &descriptor)
{
    downQueue->push(descriptor);
    return true;
}

void DownloadFiles::incomingConnection(qintptr handle)
{
//    qDebug() << "incomingConnection" << QThread::currentThreadId();
    if(!addTask(handle))
    {
        QTcpSocket * socket = nextPendingConnection();
        if(socket != nullptr)
            socket->close();
    }
}




















