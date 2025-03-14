package=native_cctools
$(package)_version=164f42296d56fd9456cb9e969ad6cf95e430cb39
$(package)_download_path=https://github.com/tpoechtrager/cctools-port/archive
$(package)_file_name=$($(package)_version).tar.gz
$(package)_sha256_hash=63245936FD9B71CFB0C671B076E243E649F6438035651C7EE5706FB66A28FB3D
$(package)_build_subdir=cctools
$(package)_dependencies=native_libtapi

define $(package)_set_vars
  $(package)_config_opts=--target=$(host)
  $(package)_ldflags+=-Wl,-rpath=\\$$$$$$$$\$$$$$$$$ORIGIN/../lib
  ifeq ($(strip $(FORCE_USE_SYSTEM_CLANG)),)
  $(package)_config_opts+=--enable-lto-support --with-llvm-config=$(build_prefix)/bin/llvm-config
  endif
  $(package)_cc=$(clang_prog)
  $(package)_cxx=$(clangxx_prog)
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
  rm -rf share
endef
