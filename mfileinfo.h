#ifndef MFILEINFO_H
#define MFILEINFO_H

#include <QFileInfo>
#include <QHash>
#include <QFileDialog>
#include <QDateTime>
#include <QStandardPaths>
#include <QDebug>
#include "setting.h"

class MFileInfo : public QObject
{
    Q_OBJECT
public:
    explicit MFileInfo(){};
    ~MFileInfo(){};

    static MFileInfo *getInstance();
    Q_INVOKABLE bool addFile(QString name);
    Q_INVOKABLE bool setFile(const QString name);
    Q_INVOKABLE QString getFileName();
    Q_INVOKABLE QString getFilePath();
    Q_INVOKABLE qint64 getFileSize();
    Q_INVOKABLE bool remove(QString name);

    Q_INVOKABLE void setPath(QString path);
    Q_INVOKABLE bool cdUp();
    Q_INVOKABLE bool isFile(qint32 i);
    Q_INVOKABLE bool isDir(qint32 i);
    Q_INVOKABLE void setSelectDir(bool state);
    Q_INVOKABLE QString getAbsolutePath();
    Q_INVOKABLE QString getAbsoluteFilePath(qint32 i);
    Q_INVOKABLE qint32 getEntryCount(); // 获取文件条目的数量
    Q_INVOKABLE QString getFilePath(qint32 i);
    Q_INVOKABLE QString getName(qint32 i);
    Q_INVOKABLE qint64 getFileSize(qint32 i);
    Q_INVOKABLE qint32 getDirCount(qint32 i);
    Q_INVOKABLE QString getDate(qint32 i);

    Q_INVOKABLE QString fileSizeFormat(qint64 size);

private:
    bool isSelectDir;
    QHash<QString, quint32> fileHash;
    QFileInfo info;
    QDir dir;
    QFileInfoList fileInfoList;

};

#endif // MFILEINFO_H


