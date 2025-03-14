package=native_ds_store
$(package)_version=738cf71c60d883e87ecaa272708672d3b5d8c8c9
$(package)_download_path=https://github.com/al45tair/ds_store/archive/
$(package)_file_name=$($(package)_version).tar.gz
$(package)_sha256_hash=8BBCFE6209F5B225275E19439B372958EFD780822B0F13FA8463A1D72FF246FC
$(package)_install_libdir=$(build_prefix)/lib/python3/dist-packages

define $(package)_build_cmds
    python3 setup.py build
endef

define $(package)_stage_cmds
    mkdir -p $($(package)_install_libdir) && \
    python3 setup.py install --root=$($(package)_staging_dir) --prefix=$(build_prefix) --install-lib=$($(package)_install_libdir)
endef
