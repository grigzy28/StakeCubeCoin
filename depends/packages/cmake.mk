package=cmake
$(package)_version=3.31.0
$(package)_download_path=https://cmake.org/files/v3.31/
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=0FCB338B4515044F9AC77543550AC92C314C58F6F95AAFCAC5CD36AA75DB6924

define $(package)_config_cmds
  export CC="" && \
  export CXX="" && \
  ./bootstrap --prefix=$(host_prefix) -- -DCMAKE_USE_OPENSSL=OFF
endef

define $(package)_build_cmds
  $(MAKE)
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef

