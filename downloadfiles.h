#ifndef DOWNLOADFILES_H
#define DOWNLOADFILES_H

#define DOWNLOAD_THREAD_SUM 4

#include "taskbase.h"
#include <QTcpServer>
#include <QNetworkInterface>
#include <QHostInfo>

#include "setting.h"
#include "hostinfo.h"

class DownloadTask : public TaskBase
{
    Q_OBJECT
public:
    explicit DownloadTask(qint32 id,BlockingQueue<qintptr> * queue);
    ~DownloadTask();

private:

    FileInfo * downFileInfo;
    bool isFirst;
    BlockingQueue<qintptr> * downQueue;
    qint64 downFileSize;
    QString downFileName;
    qint64 counter;   // 记录已传输大小
    qint64 tCounter;
    QElapsedTimer timer;
    QElapsedTimer timer2;

    void initSocket() override;
    bool initFile(FileInfo * fileInfo) override;
    void RWData() override;

};

class DownloadFiles : public QTcpServer
{
    Q_OBJECT
public:
    explicit DownloadFiles();
    ~DownloadFiles();

    static DownloadFiles *getInstance();

    Q_INVOKABLE bool startServer();
    Q_INVOKABLE void stopServer();
    Q_INVOKABLE QString getServerIP();
    Q_INVOKABLE quint16 getServerPort();
    Q_INVOKABLE void deleteTask(qint32 id);


private:
    DownloadTask * threadPool[DOWNLOAD_THREAD_SUM];
    BlockingQueue<qintptr> * downQueue;
    bool addTask(qintptr &descriptor);
    void incomingConnection(qintptr handle) override;

signals:
    void startDownTask(qint32 id,QString name,qint64 size,QString ip,quint16 port);
    void endDownTask(qint32 id,bool state);    // 结束下载时发送
    void downProgressValue(qint32 id, float value); // 更新上传进度时发送
    void downSpeed(qint32 id,qint64 speed); // 更新上传速度时发送
};



#endif // DOWNLOADFILES_H
