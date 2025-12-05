package=libxcb
$(package)_version=1.17.0
$(package)_download_path=https://x.org/archive/individual/xcb/
$(package)_file_name=$(package)-$($(package)_version).tar.xz
$(package)_sha256_hash=599EBF9996710FEA71622E6E184F3A8AD5B43D0E5FA8C4E407123C88A59A6D55
$(package)_dependencies=xcb_proto libXau
$(package)_patches = remove_pthread_stubs.patch
$(package)_patches += change_linked_libraries.patch
$(package)_patches += libxcb_libxau.patch

define $(package)_set_vars
$(package)_config_opts = --enable-static --disable-shared --disable-devel-docs --without-doxygen --without-launchd
$(package)_config_opts += --disable-dependency-tracking --enable-option-checking
# Disable unneeded extensions.
# More info is available from: https://doc.qt.io/qt-5.15/linux-requirements.html
$(package)_config_opts += --disable-composite --disable-damage --disable-dpms
$(package)_config_opts += --disable-dri2 --disable-dri3 --disable-glx
$(package)_config_opts += --disable-present --disable-record --disable-resource
$(package)_config_opts += --disable-screensaver --disable-xevie --disable-xfree86-dri
$(package)_config_opts += --disable-xinput --disable-xprint --disable-selinux
$(package)_config_opts += --disable-xtest --disable-xv --disable-xvmc
endef

define $(package)_preprocess_cmds
  cp -f $(BASEDIR)/config.guess $(BASEDIR)/config.sub build-aux && \
  patch -p1 -i $($(package)_patch_dir)/remove_pthread_stubs.patch && \
  patch -p0 -i $($(package)_patch_dir)/change_linked_libraries.patch
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) && \
  ${MAKE} DESTDIR=$($(package)_staging_dir) install
endef
#  patch -p0 -f -i $($(package)_patch_dir)/libxcb_libxau.patch && \

define $(package)_postprocess_cmds
  rm -rf share lib/*.la
endef
