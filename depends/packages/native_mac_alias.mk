package=native_mac_alias
$(package)_version=bb20cd5bbc51248de15473da585d45eb83ca8217
$(package)_download_path=https://github.com/al45tair/mac_alias/archive/
$(package)_file_name=$($(package)_version).tar.gz
$(package)_sha256_hash=521D7D4EAA0E8AEEDBE14FB21AAAF7A2973C55793D97BDFF73A03AEEC995F7A7
$(package)_install_libdir=$(build_prefix)/lib/python3/dist-packages

define $(package)_build_cmds
    python3 setup.py build
endef

define $(package)_stage_cmds
    mkdir -p $($(package)_install_libdir) && \
    python3 setup.py install --root=$($(package)_staging_dir) --prefix=$(build_prefix) --install-lib=$($(package)_install_libdir)
endef
