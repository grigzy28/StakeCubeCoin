package=cmake
$(package)_version=3.31.6
$(package)_download_path=https://cmake.org/files/v3.31/
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=653427F0F5014750AAFFF22727FB2AA60C6C732CA91808CFB78CE22DDD9E55F0

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
