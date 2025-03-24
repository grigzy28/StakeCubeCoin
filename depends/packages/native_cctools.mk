package=native_cctools
$(package)_version=81f205e8ca6bbf2fdbcb6948132454fd1f97839e
$(package)_download_path=https://github.com/tpoechtrager/cctools-port/archive
$(package)_file_name=$($(package)_version).tar.gz
$(package)_sha256_hash=9A836315380F35180F4E8BAE0247ED2DAC899AD5BA8F43879435977099F69E63
$(package)_build_subdir=cctools
$(package)_dependencies=cmake native_libtapi libdispatch

define $(package)_set_vars
  $(package)_config_opts=--target=$(host)
  $(package)_ldflags+=-Wl,-rpath=\\$$$$$$$$\$$$$$$$$ORIGIN/../lib -fuse-ld=ld
#  ifeq ($(strip $(FORCE_USE_SYSTEM_CLANG)),)
  $(package)_config_opts+= --enable-lto-support --with-llvm-config=$(build_prefix)/bin/llvm-config
#  endif
  $(package)_cc=$(clang_prog)
  $(package)_cxx=$(clangxx_prog)
endef

define $(package)_config_cmds
  LDFLAGS="$(LDFLAGS) -fuse-ld=ld " $($(package)_autoconf) --include=$($(package)_staging_dir)/include
endef

define $(package)_build_cmds
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef

define $(package)_postprocess_cmds
  rm -rf share
endef
