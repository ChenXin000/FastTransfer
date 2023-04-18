#ifndef HOSTINFO_H
#define HOSTINFO_H

#include <QNetworkInterface>
#include <QHash>
#include <unordered_map>

class HostInfo
{
public:
    explicit HostInfo();

    static void initHostIP();
    static void initAddressHash();
    static QNetworkInterface getInterface(QHostAddress &addr);
    static QList<QHostAddress> &getAddressList();
    static qint32 getAddressCount();
    static QHostAddress &getHostIP();
    static quint16 &getHostPort();
    static QHostAddress &getMulticastIP();
    static void setMulticastIP(QHostAddress &addr);
    static void setHostIP(QHostAddress &addr);
    static void setHostPort(quint16 port);

    static bool isLocalIP(QHostAddress &addr);

private:
    static QList<QHostAddress> ipv4AddrList;
    static QHash<QHostAddress,int> addressHash;
    static QHostAddress multicastIP;
    static QHostAddress hostIP;
    static quint16 hostPort;
};

#endif // HOSTINFO_H
