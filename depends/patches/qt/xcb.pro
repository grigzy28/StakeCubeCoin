TEMPLATE = subdirs
CONFIG += ordered
QT_FOR_CONFIG += gui-private

contains(QT_CONFIG, xcb-qt):SUBDIRS+=xcb-static
SUBDIRS += xcb_qpa_lib.pro
SUBDIRS += xcb-plugin.pro
SUBDIRS += gl_integrations
