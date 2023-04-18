#include "fileinfo.h"

FileInfo::FileInfo() : bufferSize(sizeof (dataLength) + FILE_NAME_LENGTH + sizeof (fileSize))
{
    buffer = new char[bufferSize];
}

FileInfo::~FileInfo()
{
    delete [] buffer;
}
// 设置主机地址端口
void FileInfo::setHost(qint32 id,const QString &addr, quint16 port)
{
    this->id = id;
    this->address = addr;
    this->port = port;
}
// 设置文件信息（文件名，文件大小）
void FileInfo::setInfo(const QString &name, qint64 size)
{
    QByteArray array = name.toUtf8();
    qint32 fileNameLen = array.size();
    dataLength = sizeof (dataLength) + fileNameLen + sizeof (fileSize);
    memcpy(buffer,&dataLength,sizeof (dataLength));
    memcpy(buffer + sizeof (dataLength),array.data(),fileNameLen);
    memcpy(buffer + sizeof (dataLength) + fileNameLen,&size,sizeof (fileSize));
}
// 设置文件信息（文件路径，文件名，文件大小）
void FileInfo::setInfo(const QString &path, const QString &name, qint64 size)
{
    setInfo(name,size);
    filePath = path;
}
// 设置文件信息（文件名，文件大小，文件偏移）
void FileInfo::setInfo(const QString &name, qint64 size, qint64 offset)
{
    setInfo(name,size);
    fileOffset = offset;
}
// 获取文件名
QString &FileInfo::getFileName()
{
    fileName = QString::fromUtf8(buffer + sizeof (dataLength),getDataLength() - sizeof (dataLength) - sizeof (fileSize));
    return fileName;
}
// 获取文件路径
QString &FileInfo::getFilePath()
{
    return filePath;
}
// 获取文件大小
qint64 FileInfo::getFileSize()
{
    memcpy(&fileSize,buffer + (getDataLength() - sizeof (fileSize)),sizeof (fileSize));
    return fileSize;
}
// 获取文件偏移
qint64 FileInfo::getFileOffset()
{
    return fileOffset;
}
// 获取文件信息的数据长度
qint32 FileInfo::getDataLength()
{
    memcpy(&dataLength,buffer,sizeof (dataLength));
    return dataLength;
}
// 获取文件ID（用于区分并操作文件）
qint32 FileInfo::getId(){return id;}
// 获取文件信息数据的缓冲区
qint32 FileInfo::getBufferSize(){return bufferSize;}
// 获取缓冲区大小
char * FileInfo::getBuffer(){return buffer;}
// 获取主机地址
QString &FileInfo::getHostAddress(){return address;}
// 获取主机端口
qint16 FileInfo::getHostPort(){return port;}
















