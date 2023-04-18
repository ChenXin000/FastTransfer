#include "udpserver.h"
#include "uploadfiles.h"
#include "downloadfiles.h"
#include "mfileinfo.h"
#include "setting.h"

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#endif
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QQuickStyle>
#include <QFont>
#include <QIcon>

#include <QTcpServer>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/logo.png"));
    QFont font;
    font.setFamily("Arial");
    app.setFont(font);


//    QCoreApplication::setOrganizationName("QtProject");
//        QCoreApplication::setApplicationName("Application Example");
//        QCoreApplication::setApplicationVersion(QT_VERSION_STR);
//        QCommandLineParser parser;
//        parser.setApplicationDescription(QCoreApplication::applicationName());
//        parser.addHelpOption();
//        parser.addVersionOption();
//        parser.addPositionalArgument("file", "The file to open.");
//        parser.process(app);

#ifdef Q_OS_ANDROID
    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.WRITE_EXTERNAL_STORAGE");
        if(r == QtAndroid::PermissionResult::Denied)
            QtAndroid::requestPermissionsSync(QStringList()<<"android.permission.WRITE_EXTERNAL_STORAGE");
#endif

//            QDir dir;
//            qDebug() << dir.entryList(QDir::NoDotAndDotDot,QDir::Name);

    QCoreApplication::setOrganizationName("FastTransfer");
    QQmlApplicationEngine engine;

//    qmlRegisterType<Setting>("Setting",1,0,"Setting");
//    qmlRegisterType<UdpServer>("UdpServer",1,0,"UdpServer");
//    qmlRegisterType<UploadFiles>("UploadFiles",1,0,"UploadFiles");
//    qmlRegisterType<DownloadFiles>("DownloadFiles",1,0,"DownloadFiles");

    qmlRegisterSingletonInstance("Setting",1,0,"Setting",Setting::getInstance());
    qmlRegisterSingletonInstance("MFileInfo",1,0,"MFileInfo",MFileInfo::getInstance());
    qmlRegisterSingletonInstance("UdpServer",1,0,"UdpServer",UdpServer::getInstance());
    qmlRegisterSingletonInstance("UploadFiles",1,0,"UploadFiles",UploadFiles::getInstance());
    qmlRegisterSingletonInstance("DownloadFiles",1,0,"DownloadFiles",DownloadFiles::getInstance());

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
