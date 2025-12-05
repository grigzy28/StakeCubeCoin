package=dbus
$(package)_version=1.15.0
$(package)_download_path=https://dbus.freedesktop.org/releases/dbus
$(package)_file_name=$(package)-$($(package)_version).tar.xz
$(package)_sha256_hash=5073C8CB9AD20226647BB38F4965182B762A6E1F595CCDC8E59411014BFD640A
$(package)_dependencies=expat

define $(package)_set_vars
  $(package)_config_opts=--disable-tests --disable-doxygen-docs --disable-xml-docs --enable-static --disable-shared --without-x
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE) -C dbus libdbus-1.la
endef

define $(package)_stage_cmds
  $(MAKE) -C dbus DESTDIR=$($(package)_staging_dir) install-libLTLIBRARIES install-dbusincludeHEADERS install-nodist_dbusarchincludeHEADERS && \
  $(MAKE) DESTDIR=$($(package)_staging_dir) install-pkgconfigDATA
endef
