TARGET = qminimal

QT += \
    core-private gui-private \
    eventdispatcher_support-private fontdatabase_support-private

DEFINES += QT_NO_FOREACH

SOURCES =   main.cpp \
            qminimalintegration.cpp \
            qminimalbackingstore.cpp
HEADERS =   qminimalintegration.h \
            qminimalbackingstore.h

OTHER_FILES += minimal.json

# Use private freetype if configured
qtConfig(freetype): QMAKE_USE_PRIVATE += freetype

# --- Static library linking for depends ---
unix:!macx {
    # Adjust these paths to match your depends folder
    LIBS += $$[QT_INSTALL_LIBS]/libfontconfig.a
    LIBS += $$[QT_INSTALL_LIBS]/libfreetype.a
}

PLUGIN_TYPE = platforms
PLUGIN_CLASS_NAME = QMinimalIntegrationPlugin
!equals(TARGET, $$QT_DEFAULT_QPA_PLUGIN): PLUGIN_EXTENDS = -

load(qt_plugin)

