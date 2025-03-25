package=libnatpmp
$(package)_version=4536032ae32268a45c073a4d5e91bbab4534773a
$(package)_download_path=https://github.com/miniupnp/libnatpmp/archive
$(package)_file_name=$($(package)_version).tar.gz
$(package)_sha256_hash=543b460aab26acf91e11d15e17d8798f845304199eea2d76c2f444ec749c5383
$(package)_dependencies=cmake

define $(package)_set_vars
   $(package)_build_opts=CC="$($(package)_cc)"
   $(package)_build_opts_mingw32=CPPFLAGS=-DNATPMP_STATICLIB
   $(package)_build_opts_darwin=LIBTOOL="$($(package)_libtool)"
   $(package)_build_env+=CFLAGS="$($(package)_cflags) $($(package)_cppflags)" AR="$($(package)_ar)"
   CMAKEBIN=$(host_prefix)/bin/cmake
endef

define $(package)_config_cmds
   $(CMAKEBIN) -S . -B build
endef

define $(package)_build_cmds
   cd build && \
  $(MAKE)
endef

define $(package)_stage_cmds
   mkdir -p $($(package)_staging_prefix_dir)/include $($(package)_staging_prefix_dir)/lib && \
   cp *.h $($(package)_staging_prefix_dir)/include && \
   cp build/libnatpmp.a $($(package)_staging_prefix_dir)/lib
endef
