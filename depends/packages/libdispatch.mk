package=libdispatch
$(package)_version=9962e1b5b2f7c53745ec60a88e093544368837d0
$(package)_download_path=https://github.com/swiftlang/swift-corelibs-libdispatch/archive
$(package)_file_name=$($(package)_version).tar.gz
$(package)_sha256_hash=4FFAF43F7E1616E9B3523BA0AD73EF5BC3A5267CE5084C03F7DF41091338DC6D
#$(package)_build_subdir=build
$(package)_dependencies=cmake

# When building for Windows, we set _WIN32_WINNT to target the same Windows
# version as we do in configure. Due to quirks in libevents build system, this
# is also required to enable support for ipv6. See #19375.
define $(package)_set_vars
  $(package)_config_opts=-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
#  $(package)_config_opts=-DEVENT__DISABLE_BENCHMARK=ON -DEVENT__DISABLE_OPENSSL=ON
#  $(package)_config_opts+=-DEVENT__DISABLE_SAMPLES=ON -DEVENT__DISABLE_REGRESS=ON
#  $(package)_config_opts+=-DEVENT__DISABLE_TESTS=ON -DEVENT__LIBRARY_TYPE=STATIC
#  $(package)_cppflags += -D_GNU_SOURCE
  $(package)_cppflags_mingw32=-D_WIN32_WINNT=0x0601
  newpath:="$(host_prefix)/bin:$($(host_prefix)/native/bin:$(PATH)):"
endef

define $(package)_preprocess_cmds
  pwd
endef
#  mkdir -p $($(package)_staging_prefix_dir)/include $($(package)_staging_prefix_dir)/lib && \

define $(package)_config_cmds
  pwd && \
  echo "host prefix: ${host_prefix}" && \
  echo "config opts: ${${package}_config_opts}" && \
  LDFLAGS="$(LDFLAGS) -fuse-ld=ld " $(host_prefix)/bin/cmake $($(package)_config_opts) && \
  pwd
endef

define $(package)_build_cmds
  pwd && \
  $(MAKE)
endef

define $(package)_stage_cmds
  mkdir -p $($(package)_staging_prefix_dir)/native && \
  echo "staging dir: $($(package)_staging_dir)" && \
  $(MAKE) DESTDIR=$($(package)_staging_dir) install && \
  cp -r $($(package)_staging_dir)/usr/local/* $($(package)_staging_prefix_dir)/
endef

define $(package)_postprocess_cmds
endef

#  $(shell export PATH=$(host_prefix)/bin:$(host_prefix)/native/bin:$(PATH))

