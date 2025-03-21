package=libdispatch
$(package)_version=137b6cf3060eae87d9b367c263619c2eca5d3aac
$(package)_download_path=https://github.com/swiftlang/swift-corelibs-libdispatch/archive
$(package)_file_name=$($(package)_version).tar.gz
$(package)_sha256_hash=0F25263ACDB746A81FDB8E7951BD1854D4BECB3F7F1119463A04DB56C7A6FDB0
$(package)_build_subdir=build
$(package)_dependencies=native_clang

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
endef

define $(package)_preprocess_cmds
endef

define $(package)_config_cmds
  $($(package)_cmake) -S .. -B .
endef

define $(package)_build_cmds
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef

define $(package)_postprocess_cmds
  rm -rf bin && \
  rm include/ev*.h && \
  rm include/event2/*_compat.h
endef
