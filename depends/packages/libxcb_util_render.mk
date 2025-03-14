package=libxcb_util_render
$(package)_version=0.3.10
$(package)_download_path=https://xcb.freedesktop.org/dist
$(package)_file_name=xcb-util-renderutil-$($(package)_version).tar.gz
$(package)_sha256_hash=E04143C48E1644C5E074243FA293D88F99005B3C50D1D54358954404E635128A
$(package)_dependencies=libxcb

define $(package)_set_vars
$(package)_config_opts=--disable-static --disable-devel-docs --without-doxygen
$(package)_config_opts += --disable-dependency-tracking --enable-option-checking
endef

define $(package)_preprocess_cmds
  cp -f $(BASEDIR)/config.guess $(BASEDIR)/config.sub .
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef

define $(package)_postprocess_cmds
  rm -rf share/man share/doc lib/*.la
endef
