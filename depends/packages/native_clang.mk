package=native_clang
$(package)_version=19.1.7
$(package)_download_path=https://github.com/grigzy28/stakecubecoin-bootstrap/releases/download/clang-llvm-$($(package)_version)-linux-x86_64
#ifneq (,$(findstring aarch64,$(BUILD)))
#$(package)_download_file=clang+llvm-$($(package)_version)-aarch64-linux-gnu.tar.xz
#$(package)_file_name=clang+llvm-$($(package)_version)-aarch64-linux-gnu.tar.xz
#$(package)_sha256_hash=90dc69a4758ca15cd0ffa45d07fbf5bf4309d47d2c7745a9f0735ecffde9c31f
#else
$(package)_download_file=clang-llvm-$($(package)_version)-linux-x86_64.tar.xz
$(package)_file_name=clang-llvm-$($(package)_version)-linux-x86_64.tar.xz
$(package)_sha256_hash=C971A93975222C23749CAA9CDECF687214736B48ECF56DC7DE02C43FA9F31647
#1838D698EC9E8CAD71361671B0AAF996B3EE9C0745FB7144B723987CECA35D3E
#endif

define $(package)_preprocess_cmds
  rm -f $($(package)_extract_dir)/lib/libc++abi.so*
endef

define $(package)_stage_cmds
  mkdir -p $($(package)_staging_prefix_dir)/lib/clang/$($(package)_version)/include && \
  mkdir -p $($(package)_staging_prefix_dir)/bin && \
  mkdir -p $($(package)_staging_prefix_dir)/include && \
  cp bin/clang $($(package)_staging_prefix_dir)/bin/ && \
  cp -P bin/clang++ $($(package)_staging_prefix_dir)/bin/ && \
  cp bin/dsymutil $($(package)_staging_prefix_dir)/bin/$(host)-dsymutil && \
  cp bin/llvm-config $($(package)_staging_prefix_dir)/bin/ && \
  cp lib/libLTO.so $($(package)_staging_prefix_dir)/lib/ && \
  cp -rf lib/clang/* $($(package)_staging_prefix_dir)/lib/clang/
endef

define $(package)_postprocess_cmds
  rmdir include
endef
