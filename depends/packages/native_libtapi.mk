package=native_libtapi
$(package)_version=54c9044082ba35bdb2b0edf282ba1a340096154c
$(package)_download_path=https://github.com/tpoechtrager/apple-libtapi/archive
$(package)_download_file=$($(package)_version).tar.gz
$(package)_file_name=$($(package)_version).tar.gz
$(package)_sha256_hash=E357F007FB61C1F6B0ABC8C5D6B960F9236D55A73E7018441C6C0FA6DF056F07
#$(package)_patches = add_environment_variable_check.patch


define $(package)_build_cmds
  pwd && \
  CC="$(clang_prog) -fuse-ld=ld " CXX="$(clangxx_prog) -fuse-ld=ld " INSTALLPREFIX=$($(package)_staging_prefix_dir) ./build.sh
endef

define $(package)_stage_cmds
  ./install.sh && \
  mkdir -p $($(package)_staging_prefix_dir)/include/llvm-c && \
  cp src/llvm/include/llvm-c/lto.h $($(package)_staging_prefix_dir)/include/llvm-c
endef
