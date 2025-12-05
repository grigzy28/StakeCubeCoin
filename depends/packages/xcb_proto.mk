package=xcb_proto
$(package)_version=1.17.0
$(package)_download_path=https://x.org/archive/individual/proto/
$(package)_file_name=xcb-proto-$($(package)_version).tar.gz
$(package)_sha256_hash=392d3c9690f8c8202a68fdb89c16fd55159ab8d65000a6da213f4a1576e97a16

define $(package)_set_vars
  $(package)_config_opts = --disable-shared
  $(package)_config_opts_linux = --with-pic
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

#  find -name "*.pyc" -delete && \
#  find -name "*.pyo" -delete
define $(package)_postprocess_cmds
  rm -rf lib/python*/site-packages/xcbgen/__pycache__
endef
