#include "setting.h"

QString Setting::downloadPath; //下载保存路径
QString Setting::tempPath;  // 临时保存路径

Setting::Setting(QObject *parent) : QObject(parent)
{
#ifdef Q_OS_ANDROID
    QString path = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation)[1];  // 获取Android内部存储路径
    downloadPath = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation)[0] + "/Download";
#else
    QString path = QCoreApplication::applicationDirPath();
    downloadPath = path + "/Download";
#endif

//    qDebug() << QStandardPaths::standardLocations(QStandardPaths::AppDataLocation);
//    qDebug() << QStandardPaths::standardLocations(QStandardPaths::AppConfigLocation);
//    qDebug() << QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation)[0];

    tempPath = path + "/temp";
    QString fileName = path + "/.config";
    settings = new QSettings(fileName,QSettings::IniFormat);
    settings->setIniCodec(QTextCodec::codecForName("UTF-8"));

    setDownloadPath(settings->value("CONFIG/path",getDownloadPath()).toString());
    setMulticastIP(settings->value("CONFIG/multicastIP",getMulticastIP()).toString());
    setHostPort(settings->value("CONFIG/port",getHostPort()).toInt());

    HostInfo::initHostIP();
    QDir dir;
    if(!dir.exists(downloadPath))
        dir.mkdir(downloadPath);
    if(!dir.exists(tempPath))
        dir.mkdir(tempPath);

}

Setting *Setting::getInstance()
{
    return new Setting;
}

QString &Setting::getTempPath()
{
    return tempPath;
}

bool Setting::fileMove(QString &src, QString &des)
{
    if(QFile::exists(des))
    {
        qint32 i = 0;
        QFileInfo info(des);
        QString path = info.absolutePath() + "/" + info.baseName() + "-";
        QString suffix = "." + info.completeSuffix();
        while(QFile::exists(path + QString::number(++i) + suffix)){}
        des = path + QString::number(i) + suffix;
    }
    return QFile::rename(src,des);
}

void Setting::setDownloadPath(QString path)
{
#ifdef Q_OS_WINDOWS
    downloadPath = path;
#else
    if(path[0] == '/') downloadPath = path;
    else downloadPath = "/" + path;
#endif
    QDir dir;
    if(!dir.exists(downloadPath))
        dir.mkdir(downloadPath);
    settings->setValue("CONFIG/path",downloadPath);
}

QString Setting::getDownloadPath()
{
    return downloadPath;
}

QStringList Setting::getAddressList()
{
    QStringList list;
    QList<QHostAddress> addrList = HostInfo::getAddressList();
    for(int i=0;i<addrList.size();i++)
        list.append(addrList[i].toString());
    return list;
}

QString Setting::getHostIP()
{
    return HostInfo::getHostIP().toString();
}

quint16 Setting::getHostPort()
{
    return HostInfo::getHostPort();
}

QString Setting::getMulticastIP()
{
    return HostInfo::getMulticastIP().toString();
}

void Setting::sync()
{
    settings->sync();
}

void Setting::setHostIP(QString ip)
{
    QHostAddress addr = QHostAddress(ip);
    HostInfo::setHostIP(addr);
}

void Setting::setHostPort(quint16 port)
{
    HostInfo::setHostPort(port);
    settings->setValue("CONFIG/port",port);
}

void Setting::setMulticastIP(QString ip)
{
    QHostAddress addr = QHostAddress(ip);
    HostInfo::setMulticastIP(addr);
    settings->setValue("CONFIG/multicastIP",ip);
}
