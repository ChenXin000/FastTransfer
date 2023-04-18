#ifndef TASKBASE_H
#define TASKBASE_H

#define READY_FLAG  'R'
#define BUFFER_SIZE (1024 * 32)

#include "blockingqueue.h"
#include "fileinfo.h"

#include <QObject>
#include <QTcpSocket>
#include <QThread>
#include <QFile>
#include <QElapsedTimer>

#include <QDebug>

class TaskBase : public QObject
{
    Q_OBJECT
public:
    explicit TaskBase();
    ~TaskBase();

    qint32 getId();
    void disconnect(){tcpSocket->disconnectFromHost();}
    void stopTask();
    bool isStopTask();

private:
    qint32 ID = -1; // 用于区别任务
    const qint32 RWBufSize = BUFFER_SIZE;
    char * RWbuffer;
    QFile * file;
    FileInfo * fileInfo;
    QTcpSocket * tcpSocket;
    QThread * taskThread;

    bool runState;
    bool isReadHead;
    bool isSendHead;
    bool isReady;
    bool stopState;
    bool transferState;

private slots:
    void init();
    void connectError(QAbstractSocket::SocketError error);
    void reconnect();

protected slots:
    virtual void RWData() = 0;

signals:
    void startTaskSignal(qint32 id,QString name,qint64 size,QString ip,quint16 port);  // 任务开始信号（开始传输时触发）
    void endTaskSignal(qint32 id,bool state);   // 任务结束信号（任务结束触发）
    void progressValueSignal(qint32 id, float value);  // 任务进度信号
    void speedSignal(qint32 id,qint64 speed);   // 任务速度信号

protected:

    virtual void initSocket() = 0;
    virtual bool initFile(FileInfo * fileInfo) = 0;

    bool readFileInfo();
    bool sendFileInfo();
    bool checkFlag();
    bool sendFlag();

    bool isRun();
    void stopRun();

    bool openFile(const QString &name,QIODevice::OpenMode mode);
    bool openFile(const QString &name,QIODevice::OpenMode mode,qint64 offset);

    void setTransferState(bool state);
    bool getTransferState();

    qint64 fileRead(char * data,qint64 maxlen);
    qint64 fileWrite(char * data, qint64 maxlen);
    bool fileAtEnd();
    bool fileFlush();
    void fileClose();
    void fileRemove();

    void connectHost(const QString &addr,quint16 port);
    bool setSocketDescriptor(qintptr descriptor);
    qint64 socketRead(char * data,qint64 maxlen);
    qint64 socketWrite(char * data,qint64 maxlen);
    qint64 socketBytesToWrite();
    bool socketAtEnd();
    bool socketFlush();
    bool socketIsValid();
    void socketClose();
    QString getSocketAddress();
    quint16 getSocketPort();

    void setFileInfo(FileInfo * info);
    FileInfo * getFileInfo();
    QFile * getFile();
    char * getRWBuffer();
    qint32 getRWBufSize();
    void setId(qint32 id);

};

#endif // TASKBASE_H
