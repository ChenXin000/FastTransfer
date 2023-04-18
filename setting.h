#ifndef SETTING_H
#define SETTING_H

#include <QObject>
#include <QDir>
#include <QSettings>
#include <QTextCodec>
#include <QCoreApplication>
#include <QStandardPaths>
#include "hostinfo.h"

class Setting : public QObject
{
    Q_OBJECT
public:
    explicit Setting(QObject *parent = nullptr);

    static Setting *getInstance();
    static QString &getTempPath();
    static bool fileMove(QString &src ,QString &des);

    Q_INVOKABLE QStringList getAddressList();

    Q_INVOKABLE QString getHostIP();
    Q_INVOKABLE quint16 getHostPort();
    Q_INVOKABLE QString getMulticastIP();
    Q_INVOKABLE void sync();

    Q_INVOKABLE static QString getDownloadPath();
    Q_INVOKABLE void setDownloadPath(QString path);

    Q_INVOKABLE void setHostIP(QString ip);
    Q_INVOKABLE void setHostPort(quint16 port);
    Q_INVOKABLE void setMulticastIP(QString ip);

private:
    static QString downloadPath;
    static QString tempPath;   // 临时下载路径
    QSettings * settings;

signals:

};

#endif // SETTING_H
