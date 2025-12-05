package=libxcb_util_image
$(package)_version=0.4.1
$(package)_download_path=https://x.org/archive/individual/xcb/
$(package)_file_name=xcb-util-image-$($(package)_version).tar.xz
$(package)_sha256_hash=ccad8ee5dadb1271fd4727ad14d9bd77a64e505608766c4e98267d9aede40d3d
$(package)_dependencies=libxcb libxcb_util libXau
$(package)_patches = fix_xutildep.patch

define $(package)_set_vars
$(package)_config_opts = --enable-static --disable-shared --disable-devel-docs --without-doxygen
$(package)_config_opts+= --disable-dependency-tracking --enable-option-checking
endef

define $(package)_preprocess_cmds
  patch -p0 -i $($(package)_patch_dir)/fix_xutildep.patch && \
  cp -f $(BASEDIR)/config.guess $(BASEDIR)/config.sub .
endef

define $(package)_config_cmds
  $($(package)_autoconf)
endef

define $(package)_build_cmds
  $(MAKE) LIBS="-lXau"
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef

define $(package)_postprocess_cmds
  rm -rf share/man share/doc lib/*.la
endef
