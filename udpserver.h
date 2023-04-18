#ifndef UDPSERVER_H
#define UDPSERVER_H

/* 数据包格式
 * +----------+-----+-----------+
 * |   head   |  0  |    flag   |
 * +----------+-----+-----------+
 * | transfer |  0  | enum Flag |
 * +----------+-----+-----------+
*/

#include <cstring>
#include <QThread>
#include <QObject>
#include <QUdpSocket>
#include <QNetworkDatagram>
#include <QNetworkInterface>
#include <QDebug>

#include "hostinfo.h"

static const char HEADER_CHECKSUM[] = {"transfer"};
static const int UDP_BUFFER_SIZE = 128;

class UdpSocket : public QUdpSocket
{
    Q_OBJECT
public:
    enum Flag {
        SCAN,
        ACTIVE,
    };
    explicit UdpSocket();
    ~UdpSocket();

private:

    char buffer[UDP_BUFFER_SIZE];
    QHostAddress tempMulticastIP = QHostAddress::Null;
    void sendDatagram(qint8 flag,const QHostAddress &host,quint16 port);
    void sendActiveFlag(const QHostAddress &host, quint16 port);

signals:
    void activeSignal(QString addr, quint16 port);
    void bindStateSignal(bool state);

public slots:
    void udpInit();
    void joinMulticastGroup();
    void udpClose();
    void readDatagram();
    void scanHost();
};

class UdpServer : public QObject
{
    Q_OBJECT

public:
    explicit UdpServer();
    ~UdpServer();

    static UdpServer * getInstance();

    Q_INVOKABLE void close();
    Q_INVOKABLE void bind();
    Q_INVOKABLE void bindMulticastGroup();
    Q_INVOKABLE void scanHost();

private:
    UdpSocket * udpSocket;
    QThread * thread;

signals:
    void joinMulticastGroupSig();
    void bindStateSig(bool state);
    void closeSig();
    void scanSig();
    void bindSig();
    void availableHost(QString ip, quint16 port);

};

#endif // UDPSERVER_H
