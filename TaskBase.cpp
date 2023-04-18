#include "taskbase.h"

TaskBase::TaskBase()
{
    RWbuffer = new char[RWBufSize];
    taskThread = new QThread;
    moveToThread(taskThread);
    connect(taskThread,&QThread::started,this,&TaskBase::init);
    taskThread->start();
}

TaskBase::~TaskBase()
{
    runState = false;
    tcpSocket->close();
    taskThread->quit();
    taskThread->wait();
    taskThread->deleteLater();
    tcpSocket->deleteLater();
    file->deleteLater();
    if(fileInfo != nullptr)
        delete fileInfo;
    delete [] RWbuffer;
}

// 停止正在进行的任务
void TaskBase::stopTask()
{
    stopState = true;
}
// 任务是否停止
bool TaskBase::isStopTask()
{
    return stopState;
}
// 初始化参数和连接信号槽
void TaskBase::init()
{
    runState = true;
    file = new QFile;
    tcpSocket = new QTcpSocket;
    isReady = isReadHead = isSendHead = stopState = false;
    connect(tcpSocket,&QTcpSocket::readyRead,this,&TaskBase::RWData);
    void (QTcpSocket::*errorSignal)(QAbstractSocket::SocketError) = &QTcpSocket::error;
    connect(tcpSocket,errorSignal,this,&TaskBase::connectError,Qt::QueuedConnection);
    connect(tcpSocket,&QTcpSocket::disconnected,this,&TaskBase::reconnect,Qt::QueuedConnection);
    initSocket();
}
// socket出错时调用的槽
void TaskBase::connectError(QAbstractSocket::SocketError error)
{
    if(error == QAbstractSocket::ConnectionRefusedError)
        reconnect();
}
// 重新连接时调用的槽
void TaskBase::reconnect()
{
    isReady = isReadHead = isSendHead = stopState = false;
    if(fileInfo != nullptr)
    {
        delete fileInfo;
        fileInfo = nullptr;
//        qDebug() << "delete fileInfo OK";
    }
    emit endTaskSignal(getId(),getTransferState());
    setTransferState(false);
    if(file->isOpen())
        fileClose();
    if(isRun())
        initSocket();
}
// 读取对方发送的文件信息
bool TaskBase::readFileInfo()
{
    if(isReadHead) return isReadHead;
    if(tcpSocket->atEnd()) return isReadHead;
    qint64 len = tcpSocket->read(fileInfo->getBuffer(),fileInfo->getBufferSize());
    if(len < 0 || len != fileInfo->getDataLength() || !tcpSocket->atEnd())
        isReadHead = false;
    else if(initFile(fileInfo))
        return isReadHead = true;
    file->close();
    tcpSocket->close();
    return isReadHead;
}
// 发送文件信息给对方
bool TaskBase::sendFileInfo()
{
    if(isSendHead) return isSendHead;
    qint64 datalen = fileInfo->getDataLength();
    qint64 len = tcpSocket->write(fileInfo->getBuffer(),datalen);
    if(len < 0 || datalen != len)
        isSendHead = false;
    else if(tcpSocket->flush())
        return isSendHead = true;
    file->close();
    tcpSocket->close();
    return isSendHead;
}
// 检查标志是否正确
bool TaskBase::checkFlag()
{
    if(isReady) return isReady;
    char flag;
    isReady = (tcpSocket->getChar(&flag) && flag == READY_FLAG);
    if(!isReady)
        tcpSocket->close();
    return isReady;
}
// 发送标志（代表任务开始）
bool TaskBase::sendFlag()
{
    if(isReady) return isReady;
    isReady = (tcpSocket->putChar(READY_FLAG) && tcpSocket->flush());
    if(!isReady)
        tcpSocket->close();
    return isReady;
}
// 是否运行
bool TaskBase::isRun()
{
    return runState;
}
// 退出运行
void TaskBase::stopRun()
{
    runState = false;
}
// 打开文件
bool TaskBase::openFile(const QString &name, QIODevice::OpenMode mode)
{
    file->setFileName(name);
    if(file->open(mode))
        return true;
    return false;
}
// 打开文件并设置偏移
bool TaskBase::openFile(const QString &name, QIODevice::OpenMode mode, qint64 offset)
{
    return openFile(name,mode) && file->seek(offset);
}
// 设置传输状态（成功与失败）
void TaskBase::setTransferState(bool state)
{
    transferState = state;
}
// 获取传输状态
bool TaskBase::getTransferState()
{
    return transferState;
}
// 读取文件
qint64 TaskBase::fileRead(char *data, qint64 maxlen)
{
    return file->read(data ,maxlen);
}
// 写文件
qint64 TaskBase::fileWrite(char *data, qint64 maxlen)
{
    return file->write(data, maxlen);
}
// 文件是否到末尾
bool TaskBase::fileAtEnd()
{
    return file->atEnd();
}
// 将数据从缓冲区写入到文件
bool TaskBase::fileFlush()
{
    return file->flush();
}
// 关闭文件
void TaskBase::fileClose()
{
    file->close();
}
// 删除文件
void TaskBase::fileRemove()
{
    file->remove();
    file->close();
}
// 连接主机
void TaskBase::connectHost(const QString &addr, quint16 port)
{
    tcpSocket->connectToHost(addr,port);
}
// 设置socket描述符
bool TaskBase::setSocketDescriptor(qintptr descriptor)
{
    return tcpSocket->setSocketDescriptor(descriptor);
}
// socket读
qint64 TaskBase::socketRead(char *data, qint64 maxlen)
{
    return tcpSocket->read(data,maxlen);
}
// socket写
qint64 TaskBase::socketWrite(char *data, qint64 maxlen)
{
    return tcpSocket->write(data, maxlen);
}
// 返回等待写入的字节数
qint64 TaskBase::socketBytesToWrite()
{
    return tcpSocket->bytesToWrite();
}
// socket数据是否到末尾
bool TaskBase::socketAtEnd()
{
    return tcpSocket->atEnd();
}
// 数据从缓冲区写入底层socket
bool TaskBase::socketFlush()
{
#ifdef Q_OS_WINDOWS
    return tcpSocket->flush();
#else
    return tcpSocket->waitForBytesWritten(20);
#endif
}
// socket是否有效
bool TaskBase::socketIsValid()
{
    return tcpSocket->isValid();
}
// 关闭socket
void TaskBase::socketClose()
{
    tcpSocket->close();
}
// 获取已连接的主机地址
QString TaskBase::getSocketAddress()
{
    return tcpSocket->peerAddress().toString();
}
// 获取已连接的主机端口
quint16 TaskBase::getSocketPort()
{
    return tcpSocket->peerPort();
}
// 设置文件信息
void TaskBase::setFileInfo(FileInfo *info)
{
    fileInfo = info;
}
// 获取文件信息
FileInfo *TaskBase::getFileInfo()
{
    return fileInfo;
}
// 获取传输时的读写缓冲区
char *TaskBase::getRWBuffer()
{
    return RWbuffer;
}
// 获取缓冲区大小
qint32 TaskBase::getRWBufSize()
{
    return RWBufSize;
}
// 获取ID
qint32 TaskBase::getId()
{
    return ID;
}
// 设置ID
void TaskBase::setId(qint32 id)
{
    ID = id;
}




















