package=zlib
$(package)_version=1.3.1
$(package)_download_path=https://www.zlib.net/fossils/
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=9A93B2B7DFDAC77CEBA5A558A580E74667DD6FEDE4585B91EEFB60F03B72DF23

define $(package)_set_vars
$(package)_config_opts= CC="$($(package)_cc)"
$(package)_config_opts+=CFLAGS="$($(package)_cflags) $($(package)_cppflags) -fPIC"
$(package)_config_opts+=RANLIB="$($(package)_ranlib)"
$(package)_config_opts+=AR="$($(pbuild_ar))"
$(package)_config_opts_darwin+=AR="$($(build_ar)"
$(package)_config_opts_darwin+=ARFLAGS="--format=darwin r"
$(package)_config_opts_android+=CHOST=$(host)
endef

# zlib has its own custom configure script that takes in options like CC,
# CFLAGS, RANLIB, AR, and ARFLAGS from the environment rather than from
# command-line arguments.
define $(package)_config_cmds
  env $($(package)_config_opts) ./configure --static --prefix=$(host_prefix)
endef

define $(package)_build_cmds
  $(MAKE) libz.a
endef

define $(package)_stage_cmds
  $(MAKE) DESTDIR=$($(package)_staging_dir) install
endef

