#include "udpserver.h"

UdpSocket::UdpSocket(){}
UdpSocket::~UdpSocket(){}

void UdpSocket::udpInit()
{
    QHostAddress addr;
    if(isValid())
        abort();

#ifdef Q_OS_ANDROID
    addr = QHostAddress::AnyIPv4;
#else
    if(HostInfo::getAddressCount() <= 1)
        addr = QHostAddress::AnyIPv4;
    else addr = HostInfo::getHostIP();
#endif

    if(QUdpSocket::bind(addr,HostInfo::getHostPort(),QAbstractSocket::ShareAddress | QAbstractSocket::ReuseAddressHint))
    {
        QUdpSocket::setSocketOption(QAbstractSocket::MulticastLoopbackOption,0);
        joinMulticastGroup();
    }
    else
        emit bindStateSignal(false);
}

void UdpSocket::joinMulticastGroup()
{
    QHostAddress addr = HostInfo::getHostIP();
    if(tempMulticastIP != QHostAddress::Null)
    {
        if(QUdpSocket::leaveMulticastGroup(tempMulticastIP,HostInfo::getInterface(addr)))
            tempMulticastIP = QHostAddress::Null;
    }
    bool state = QUdpSocket::joinMulticastGroup(HostInfo::getMulticastIP(),HostInfo::getInterface(addr));
    if(state)
        tempMulticastIP = HostInfo::getMulticastIP();
    emit bindStateSignal(state);
}

void UdpSocket::udpClose()
{
    close();
}

void UdpSocket::readDatagram()
{
    QHostAddress addr;
    quint16 port;
    while(hasPendingDatagrams())
    {
        if(QUdpSocket::readDatagram(buffer,UDP_BUFFER_SIZE,&addr,&port) < 0)
            continue ;
//        if(HostInfo::isLocalIP(addr))
//            continue ;
        if(strcmp(buffer,HEADER_CHECKSUM))
            continue ;
        qint32 headLen = strlen(HEADER_CHECKSUM) + sizeof (char);
        if(buffer[headLen] == UdpSocket::SCAN)
            sendActiveFlag(addr,port);
        else if(buffer[headLen] == UdpSocket::ACTIVE) {
            emit activeSignal(addr.toString(),port);
        }
//        qDebug()<< "readDatagram" << addr << " " <<port;
    }

}

void UdpSocket::sendDatagram(qint8 flag, const QHostAddress &host, quint16 port)
{
    qint32 headLen = strlen(HEADER_CHECKSUM) + sizeof (char);
    char buf[headLen + sizeof (flag)];
    memcpy(buf,HEADER_CHECKSUM,headLen);
    memcpy(buf + headLen,&flag,sizeof (flag));
    writeDatagram(buf,headLen + sizeof (flag),host,port);
}

void UdpSocket::scanHost()
{
    sendDatagram(UdpSocket::SCAN,HostInfo::getMulticastIP(),HostInfo::getHostPort());
}

void UdpSocket::sendActiveFlag(const QHostAddress &host, quint16 port)
{
    sendDatagram(UdpSocket::ACTIVE,host,port);
}


UdpServer::UdpServer()
{
    udpSocket = new UdpSocket;
    thread = new QThread;
    udpSocket->moveToThread(thread);
    connect(thread,&QThread::started,udpSocket,&UdpSocket::udpInit);
    connect(udpSocket,&QUdpSocket::readyRead,udpSocket,&UdpSocket::readDatagram);

    void (UdpSocket::*bindState)(bool) = &UdpSocket::bindStateSignal;
    connect(udpSocket,bindState,this,&UdpServer::bindStateSig);
    connect(this,&UdpServer::joinMulticastGroupSig,udpSocket,&UdpSocket::joinMulticastGroup);

    connect(this,&UdpServer::scanSig,udpSocket,&UdpSocket::scanHost);
    connect(this,&UdpServer::bindSig,udpSocket,&UdpSocket::udpInit);
    connect(this,&UdpServer::closeSig,udpSocket,&UdpSocket::udpClose);

    void (UdpSocket::*activeSignal)(QString, quint16) = &UdpSocket::activeSignal;
    connect(udpSocket,activeSignal,this,&UdpServer::availableHost);
    thread->start();
}

UdpServer::~UdpServer()
{
    thread->deleteLater();
    udpSocket->deleteLater();
}

UdpServer *UdpServer::getInstance()
{
    return new UdpServer;
}

void UdpServer::close()
{
    emit closeSig();
}

void UdpServer::bind()
{
#ifdef Q_OS_ANDROID
    return ;
#else
    emit bindSig();
#endif
}

void UdpServer::bindMulticastGroup()
{
    emit joinMulticastGroupSig();
}

void UdpServer::scanHost()
{
    emit scanSig();
}







