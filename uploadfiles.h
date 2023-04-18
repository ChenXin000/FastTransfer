#ifndef UPLOADFILE_H
#define UPLOADFILE_H

#define UPLOAD_THREAD_SUM 4

#include "taskbase.h"

#include <QObject>
#include <QFileInfo>

class UploadTask : public TaskBase
{
    Q_OBJECT

public:
    UploadTask(BlockingQueue<FileInfo *> * queue);
    ~UploadTask();

private:
    QElapsedTimer timer;
    BlockingQueue<FileInfo *> * uploadQueue;
    QString upFileName;
    QString upFilePath;
    qint64 upFileSize;
    qint64 counter;   // 记录已传输的大小

    void initSocket() override;
    bool initFile(FileInfo * fileInfo) override;
    void RWData() override;
};

class UploadFiles : public QObject
{
    Q_OBJECT
public:
    explicit UploadFiles(QObject *parent = nullptr);
    ~UploadFiles();

    static UploadFiles *getInstance();

    Q_INVOKABLE bool addTask(qint32 id,QString filePath,QString address,quint16 port);
    Q_INVOKABLE bool remove(qint32 index);
    Q_INVOKABLE void deleteTask(qint32 id);

private:
    BlockingQueue<FileInfo *> * uploadQueue;
    UploadTask * threadPool[UPLOAD_THREAD_SUM];

signals:
    void startUpTask(qint32 id,QString name, qint64 size,QString host); // 开始上传时发送
    void endUpTask(qint32 id,bool state);   // 上传结束发送
    void upProgressValue(qint32 id, float value); // 更新上传进度时发送
    void upSpeed(qint32 id, qint64 speed);   // 更新上传速度时发送
};

#endif // UPLOADFILE_H
