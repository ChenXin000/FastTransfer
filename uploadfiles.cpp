#include "uploadfiles.h"

UploadTask::UploadTask(BlockingQueue<FileInfo *> * queue) : uploadQueue(queue)
{
}

UploadTask::~UploadTask()
{
    stopRun();
    uploadQueue->quit();
}
/*
 * 重写初始化socket
 * 从队列中取出文件信息并连接主机
*/
void UploadTask::initSocket()
{
//    qDebug() << "UploadTask:initSocket";
    TaskBase::setId(-1);
    FileInfo * fileInfo = uploadQueue->pop();
    TaskBase::setFileInfo(fileInfo);
    TaskBase::setId(fileInfo->getId());
    upFileName = fileInfo->getFileName();
    upFilePath = fileInfo->getFilePath() + "/";
    upFileSize = fileInfo->getFileSize();
    emit startTaskSignal(TaskBase::getId(),upFileName,upFileSize,fileInfo->getHostAddress(),fileInfo->getHostPort());
    if(!TaskBase::isRun())
        return ;
    connectHost(fileInfo->getHostAddress(),fileInfo->getHostPort());

//    qDebug() << "UploadTask " << upFileName << " " << upFilePath <<" " << upFileSize;
}
/*
 * 重写文件初始化
 * 读取文件信息成功后调用
 * 打开文件并设置文件大小
*/
bool UploadTask::initFile(FileInfo *fileInfo)
{
    if(upFileName != fileInfo->getFileName())
        return false;
    counter = fileInfo->getFileSize(); // 获取上次已传输的大小
    return openFile(upFilePath + upFileName,QIODevice::ReadOnly,counter);
}
/*
 * 重写读写数据的槽
*/
void UploadTask::RWData()
{
    char * buffer = getRWBuffer();
    if(!checkFlag() || !sendFileInfo() || !readFileInfo())
        return ;
    QElapsedTimer timer;
    QElapsedTimer timer2;
    qint64 tCounter = counter;
    timer.start();
    timer2.start();
    while(!fileAtEnd() && !isStopTask() && socketIsValid())
    {
        qint64 Rlen = fileRead(buffer,getRWBufSize());
        if(Rlen < 0)
            break;
        qint64 Wlen = socketWrite(buffer,Rlen);
        if(Wlen < 0)
            break;
        while(!socketFlush())
        {
            if(!socketIsValid() || isStopTask())
                break;
            if(timer.hasExpired(500))
                break;
        }
        counter += Wlen;
        if(timer.hasExpired(20))
        {
            float progress = ((float)counter / (float)upFileSize);  // 进度值
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
    socketClose();
    fileClose();
    setTransferState(counter == upFileSize);
}

UploadFiles::UploadFiles(QObject *parent) : QObject(parent)
{
    uploadQueue = new BlockingQueue<FileInfo *>;
    void (UploadTask::*startTask)(qint32, QString, qint64, QString, quint16) = &UploadTask::startTaskSignal;
    void (UploadTask::*endTask)(qint32, bool) = &UploadTask::endTaskSignal;
    void (UploadTask::*progressValue)(qint32, float) = &UploadTask::progressValueSignal;
    void (UploadTask::*speed)(qint32, qint64) = &UploadTask::speedSignal;
    for(int i=0;i<UPLOAD_THREAD_SUM;i++)
    {
        threadPool[i] = new UploadTask(uploadQueue);
        connect(threadPool[i],startTask,this,&UploadFiles::startUpTask);
        connect(threadPool[i],endTask,this,&UploadFiles::endUpTask);
        connect(threadPool[i],progressValue,this,&UploadFiles::upProgressValue);
        connect(threadPool[i],speed,this,&UploadFiles::upSpeed);
    }
}

UploadFiles::~UploadFiles()
{
    for(int i=0;i<UPLOAD_THREAD_SUM;i++)
        threadPool[i]->deleteLater();
    delete uploadQueue;
}

UploadFiles *UploadFiles::getInstance()
{
    return new UploadFiles;
}

bool UploadFiles::addTask(qint32 id, QString filePath, QString address, quint16 port)
{
    FileInfo * upFileInfo = new FileInfo;
    QFileInfo info(filePath);
    upFileInfo->setInfo(info.path(),info.fileName(),info.size());
    upFileInfo->setHost(id,address,port);
    uploadQueue->push(upFileInfo);
    return true;
}

bool UploadFiles::remove(qint32 index)
{
    FileInfo * info = uploadQueue->remove(index);
    if(info == nullptr)
        return false;
    delete info;
    return true;
}

void UploadFiles::deleteTask(qint32 id)
{
    for(int i=0;i<UPLOAD_THREAD_SUM;i++)
        if(threadPool[i]->getId() == id)
            threadPool[i]->stopTask();
}













