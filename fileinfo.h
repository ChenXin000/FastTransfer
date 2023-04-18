#ifndef FILEINFO_H
#define FILEINFO_H

#define FILE_NAME_LENGTH  255

#include <QHostAddress>
#include <QString>

class FileInfo
{
public:
    explicit FileInfo();
    ~FileInfo();

    void setInfo(const QString &name,qint64 size);
    void setInfo(const QString &path,const QString &name,qint64 size);
    void setInfo(const QString &name,qint64 size,qint64 offset);
    void setHost(qint32 id, const QString &addr, quint16 port);

    char * getBuffer();
    qint32 getBufferSize();
    QString &getFileName();
    QString &getFilePath();
    qint64 getFileSize();
    qint64 getFileOffset();
    qint32 getDataLength();

    qint32 getId();
    QString &getHostAddress();
    qint16 getHostPort();

private:
    qint32 id;
    qint16 port;
    QString address;
    qint32 dataLength;
//    qint32 count;
    char * buffer;
    QString fileName;
    QString filePath;
    qint64 fileSize;
    qint64 fileOffset;
    const qint32 bufferSize;
};
#endif // FILEINFO_H
