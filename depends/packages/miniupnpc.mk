package=miniupnpc
$(package)_version=2.3.2
#$(package)_download_path=https://miniupnp.tuxfamily.org/files/
$(package)_download_path=https://github.com/miniupnp/miniupnp/releases/download/miniupnpc_2_3_2/
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=985DE16D2E5449C3BA0D3663A0C76CB2BFF82472A0EB7A306107D93F44586FFE
#$(package)_patches=dont_use_wingen.patch
$(package)_build_subdir=build
$(package)_dependencies=cmake


define $(package)_set_vars
$(package)_build_opts=CC="$($(package)_cc)"
$(package)_build_opts_darwin=LIBTOOL="$($(package)_libtool)"
$(package)_build_env+=CFLAGS="$($(package)_cflags) $($(package)_cppflags)" AR="$($(package)_ar)"
CMAKEBIN=$(host_prefix)/bin/cmake
endef

define $(package)_preprocess_cmds
  mkdir dll && \
  sed -e 's|MINIUPNPC_VERSION_STRING \"version\"|MINIUPNPC_VERSION_STRING \"$($(package)_version)\"|' -e 's|OS/version|$(host)|' miniupnpcstrings.h.in > miniupnpcstrings.h
endef
#  patch -p1 < $($(package)_patch_dir)/dont_use_wingen.patch

define $(package)_config_cmds
   $(CMAKEBIN) -S .. -B .
endef

define $(package)_build_cmds
  $(MAKE) $($(package)_build_opts)
endef

define $(package)_stage_cmds
	mkdir -p $($(package)_staging_prefix_dir)/include/miniupnpc $($(package)_staging_prefix_dir)/lib &&\
	install *.h $($(package)_staging_prefix_dir)/include/miniupnpc &&\
	install libminiupnpc.a $($(package)_staging_prefix_dir)/lib
endef
