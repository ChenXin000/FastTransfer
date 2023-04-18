#include "hostinfo.h"

QHash<QHostAddress,int> HostInfo::addressHash;
QList<QHostAddress> HostInfo::ipv4AddrList;
QHostAddress HostInfo::multicastIP = QHostAddress("224.0.0.120");
QHostAddress HostInfo::hostIP = QHostAddress::AnyIPv4;
quint16 HostInfo::hostPort = 6200;

HostInfo::HostInfo(){}

void HostInfo::initHostIP()
{
    QList<QHostAddress> addrList = getAddressList();
    if(addrList.size() > 0)
        hostIP = addrList[0];
//    for(int i=0;i<addrList.size();i++)
//    {
//        if(!addrList[i].isLoopback() && addrList[i].protocol() == QAbstractSocket::IPv4Protocol)
//        {
//            hostIP = addrList[i];
//            return ;
//        }
//    }
}

void HostInfo::initAddressHash()
{
    addressHash.clear();
    QList<QNetworkInterface> interfaceList = QNetworkInterface::allInterfaces();
    for(int i=0;i<interfaceList.size();i++)
    {
        if(interfaceList[i].index() < 0)
            continue;
        QList<QNetworkAddressEntry> entry = interfaceList[i].addressEntries();
        for(int j=0;j<entry.size();j++)
        {
            QHostAddress ip = entry[j].ip();
            if(ip.protocol() == QAbstractSocket::IPv4Protocol)
                addressHash[ip] = interfaceList[i].index();
        }
    }
}

QNetworkInterface HostInfo::getInterface(QHostAddress &addr)
{
    return QNetworkInterface::interfaceFromIndex(addressHash[addr]);
}

QList<QHostAddress> &HostInfo::getAddressList()
{
    initAddressHash();
    ipv4AddrList.clear();
    QList<QHostAddress> list = QNetworkInterface::allAddresses();
    for(int i=0;i<list.size();i++)
    {
        if(list[i].protocol() == QAbstractSocket::IPv4Protocol && !list[i].isLoopback())
            ipv4AddrList.append(list[i]);
    }
    return ipv4AddrList;
}

qint32 HostInfo::getAddressCount()
{
    return ipv4AddrList.size();
}

QHostAddress &HostInfo::getHostIP()
{
    return hostIP;
}

quint16 &HostInfo::getHostPort()
{
    return hostPort;
}

QHostAddress &HostInfo::getMulticastIP()
{
    return multicastIP;
}

void HostInfo::setMulticastIP(QHostAddress &addr)
{
    multicastIP = addr;
}

void HostInfo::setHostIP(QHostAddress &addr)
{
    if(addressHash.find(addr) == addressHash.end())
        return ;
    hostIP = addr;
}

void HostInfo::setHostPort(quint16 port)
{
    hostPort = port;
}

bool HostInfo::isLocalIP(QHostAddress &addr)
{
    if(addressHash.find(addr) != addressHash.end())
        return true;
    return false;
}



