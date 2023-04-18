#include "mfileinfo.h"

MFileInfo *MFileInfo::getInstance()
{
    return new MFileInfo;
}
// 添加文件并去重
bool MFileInfo::addFile(QString name)
{
    if(info.isDir() || !info.exists() || !info.size())
        return false;
    if(++fileHash[name] > 1)
        return false;
    return true;
}

bool MFileInfo::setFile(const QString name)
{
//#ifdef Q_OS_WINDOWS
//    info.setFile(name);
//#else
//    info.setFile("/" + name);
//#endif
    info.setFile(name);
    return addFile(info.fileName());
}

QString MFileInfo::getFileName()
{
    return info.fileName();
}

QString MFileInfo::getFilePath()
{
    return info.path();
}

qint64 MFileInfo::getFileSize()
{
    return info.size();
}
// 移除文件
bool MFileInfo::remove(QString name)
{
    return fileHash.remove(name);
}
// 设置访问路径
void MFileInfo::setPath(QString path)
{
    dir.setPath(path);
    if(dir.exists())
    {
        if(isSelectDir)  // 只选择目录
            fileInfoList = dir.entryInfoList(QDir::NoDotAndDotDot | QDir::Dirs, QDir::Name | QDir::DirsFirst);
        else  // 选择文件
            fileInfoList = dir.entryInfoList(QDir::NoDotAndDotDot | QDir::Dirs | QDir::Files, QDir::Name | QDir::DirsFirst);
    }
}
// 返回目录上一级
bool MFileInfo::cdUp()
{
    if(!dir.cdUp())
        return false;
    if(isSelectDir)
        fileInfoList = dir.entryInfoList(QDir::NoDotAndDotDot | QDir::Dirs, QDir::Name | QDir::DirsFirst);
    else
        fileInfoList = dir.entryInfoList(QDir::NoDotAndDotDot | QDir::Dirs | QDir::Files, QDir::Name | QDir::DirsFirst);
    return true;
}
// 是否是文件
bool MFileInfo::isFile(qint32 i)
{
    return fileInfoList[i].isFile();
}
// 是否是目录
bool MFileInfo::isDir(qint32 i)
{
    return fileInfoList[i].isDir();
}
// 设置是否选择目录
void MFileInfo::setSelectDir(bool state)
{
    isSelectDir = state;
    if(state)
        setPath(Setting::getDownloadPath());
    else
        setPath(QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation)[0]);
}

// 获取当前绝对路径
QString MFileInfo::getAbsolutePath()
{
    return dir.absolutePath();
}
// 获取文件绝对路径（包含文件名）
QString MFileInfo::getAbsoluteFilePath(qint32 i)
{
    return fileInfoList[i].absoluteFilePath();
}
// 获取文件当前路径文件数量
qint32 MFileInfo::getEntryCount()
{
    return fileInfoList.size();
}
// 获取文件路径（不包含文件名）
QString MFileInfo::getFilePath(qint32 i)
{
    return fileInfoList[i].path();
}
// 获取文件名或目录名
QString MFileInfo::getName(qint32 i)
{
    QFileInfo info = fileInfoList[i];
    return info.fileName();
}
// 获取文件大小
qint64 MFileInfo::getFileSize(qint32 i)
{
    return fileInfoList[i].size();
}
// 获取目录内文件数量
qint32 MFileInfo::getDirCount(qint32 i)
{
    QDir d(fileInfoList[i].absoluteFilePath());
    d.setFilter(QDir::NoDotAndDotDot | QDir::Dirs | QDir::Files);
    return d.count();
}
// 获取文件最后一次更改时间
QString MFileInfo::getDate(qint32 i)
{
    return fileInfoList[i].lastModified().toString("yyyy-MM-dd hh:mm");
}
// 格式化文件大小GB KB B
QString MFileInfo::fileSizeFormat(qint64 size)
{
    qint64 t = size;
    if((t = t / 1024) < 1) return QString::asprintf("%lldB",size);
    if((t = t / 1024) < 1) return QString::asprintf("%.2fKB",((float)size / 1024.0));
    if((t = t / 1024) < 1) return QString::asprintf("%.2fMB",((float)size / 1024.0 / 1024));
    return QString::asprintf("%.2fGB",((float)size / 1024.0 / 1024.0 / 1024.0));
}



