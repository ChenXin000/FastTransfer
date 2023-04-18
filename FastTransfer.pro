QT       += core gui network quick quickcontrols2 widgets

android {
    QT += androidextras
}

#greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

RC_ICONS = logo.ico

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    downloadfiles.cpp \
    fileinfo.cpp \
    hostinfo.cpp \
    main.cpp \
    mfilinfo.cpp \
    setting.cpp \
    taskbase.cpp \
    udpserver.cpp \
    uploadfiles.cpp

HEADERS += \
    blockingqueue.h \
    downloadfiles.h \
    fileinfo.h \
    hostinfo.h \
    mfileinfo.h \
    setting.h \
    taskbase.h \
    udpserver.h \
    uploadfiles.h

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

RESOURCES += \
    resources/resource.qrc \
    ui/ui.qrc

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android


