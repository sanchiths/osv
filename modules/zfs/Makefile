# OSv makefile for libsolaris.so
#
# Copyright (C) 2015 Cloudius Systems, Ltd.
# This work is open source software, licensed under the terms of the
# BSD license as described in the LICENSE file in the top-level directory.

# Delete the builtin make rules, as if "make -r" was used.
.SUFFIXES:

# Ask make to not delete "intermediate" results, such as the .o in the chain
# .cc -> .o -> .so. Otherwise, during the first build, make considers the .o
# to be intermediate, and deletes it, but the newly-created ".d" files lists
# the ".o" as a target - so it needs to be created again on the second make.
# See commit fac05c95 for a longer explanation.
.SECONDARY:

# Deleting partially-build targets on error should be the default, but it
# isn't, for historical reasons, so we need to turn it on explicitly...
.DELETE_ON_ERROR:
###########################################################################
# Backward-compatibility hack to support the old "make ... image=..." image
# building syntax, and pass it into scripts/build. We should eventually drop
# this support and turn the deprecated messages into errors.
compat_args=$(if $(usrskel), usrskel=$(usrskel),)
compat_args+=$(if $(fs), fs=$(fs),)
ifdef image
#$(error Please use scripts/build to build images)
$(info "make image=..." deprecated. Please use "scripts/build image=...".)
default_target:
	./scripts/build image=$(image) $(compat_args)
endif
ifdef modules
#$(error Please use scripts/build to build images)
$(info "make modules=..." deprecated. Please use "scripts/build modules=...".)
default_target:
	./scripts/build modules=$(modules) $(compat_args)
endif
.PHONY: default_target

###########################################################################

$(out)/bootfs.bin: scripts/mkbootfs.py $(bootfs_manifest) $(bootfs_manifest_dep) $(tools:%=$(out)/%) \
		$(out)/libenviron.so $(out)/libvdso.so $(out)/libsolaris.so
	$(call quiet, olddir=`pwd`; cd $(out); "$$olddir"/scripts/mkbootfs.py -o bootfs.bin -d bootfs.bin.d -m "$$olddir"/$(bootfs_manifest), MKBOOTFS $@)

$(out)/zfs_builder_bootfs.bin: scripts/mkbootfs.py $(zfs_builder_bootfs_manifest) $(tools:%=$(out)/%) \
		$(out)/zpool.so $(out)/zfs.so $(out)/libenviron.so $(out)/libvdso.so $(out)/libsolaris.so
	$(call quiet, olddir=`pwd`; cd $(out); "$$olddir"/scripts/mkbootfs.py -o zfs_builder_bootfs.bin -d zfs_builder_bootfs.bin.d -m zfs_builder_bootfs.manifest \
		-D libgcc_s_dir=$(libgcc_s_dir), MKBOOTFS $@)

libsolaris-objects = $(foreach file, $(solaris) $(xdr), $(out)/$(file))
libsolaris-objects += $(out)/bsd/porting/kobj.o $(out)/fs/zfs/zfs_initialize.o

$(libsolaris-objects): kernel-defines = -D_KERNEL $(source-dialects) -fvisibility=hidden -ffunction-sections -fdata-sections

#build libsolaris.so with -z,now so that all symbols get resolved eagerly (BIND_NOW)
#also make sure libsolaris.so has osv-mlock note (see zfs_initialize.c) so that
# the file segments get loaded eagerly as well when mmapped
comma:=,
$(out)/libsolaris.so: $(libsolaris-objects)
	$(makedir)
	$(call quiet, $(CC) $(CFLAGS) -Wl$(comma)-z$(comma)now -Wl$(comma)--gc-sections -o $@ $(libsolaris-objects) -L$(out), LINK libsolaris.so)

libzfs-objects += $(libzpool-objects)
libzfs-objects += $(out)/bsd/cddl/compat/opensolaris/misc/mkdirp.o
libzfs-objects += $(out)/bsd/cddl/compat/opensolaris/misc/zmount.o
libzfs-objects += $(out)/bsd/cddl/contrib/opensolaris/lib/libzfs/common/zfs_prop.o
libzfs-objects += $(out)/bsd/cddl/contrib/opensolaris/lib/libzfs/common/zprop_common.o

define libzfs-includes
  bsd/cddl/compat/opensolaris/lib/libumem
  bsd/cddl/contrib/opensolaris/head
  bsd/cddl/contrib/opensolaris/lib/libzpool/common
  bsd/cddl/contrib/opensolaris/lib/libuutil/common
  bsd/cddl/compat/opensolaris/include
  bsd/cddl/contrib/opensolaris/lib/libzfs/common
  bsd/cddl/contrib/opensolaris/lib/libnvpair
  bsd/lib/libgeom
  bsd/sys/cddl/compat/opensolaris
  bsd/sys/cddl/contrib/opensolaris/uts/common
  bsd/sys/cddl/contrib/opensolaris/uts/common/sys
  bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs
  bsd/sys/cddl/contrib/opensolaris/common/zfs
  bsd/sys/cddl/contrib/opensolaris/uts/common/zmod
  bsd/include
  bsd
  bsd/sys
endef

cflags-libzfs-include = $(foreach path, $(strip $(libzfs-includes)), -isystem $(path))

$(libzfs-objects): local-includes += $(cflags-libzfs-include)

# disable the main bsd include search order, we want it before osv but after solaris
$(libzfs-objects): post-includes-bsd =

$(libzfs-objects): kernel-defines =

$(libzfs-objects): CFLAGS += -D_GNU_SOURCE

$(libzfs-objects): CFLAGS += -Wno-switch -D__va_list=__builtin_va_list '-DTEXT_DOMAIN=""' \
			-Wno-maybe-uninitialized -Wno-unused-variable -Wno-unknown-pragmas -Wno-unused-function \
			-D_OPENSOLARIS_SYS_UIO_H_

$(out)/bsd/cddl/contrib/opensolaris/lib/libzpool/common/kernel.o: CFLAGS += -fvisibility=hidden
$(out)/bsd/cddl/contrib/opensolaris/lib/libzfs/common/zfs_prop.o: CFLAGS += -fvisibility=hidden

# Note: zfs_prop.c and zprop_common.c are also used by the kernel, thus the manual targets.
$(out)/bsd/cddl/contrib/opensolaris/lib/libzfs/common/zfs_prop.o: bsd/sys/cddl/contrib/opensolaris/common/zfs/zfs_prop.c | generated-headers
	$(makedir)
	$(call quiet, $(CC) $(CFLAGS) -c -o $@ $<, CC $<)

$(out)/bsd/cddl/contrib/opensolaris/lib/libzfs/common/zprop_common.o: bsd/sys/cddl/contrib/opensolaris/common/zfs/zprop_common.c | generated-headers
	$(makedir)
	$(call quiet, $(CC) $(CFLAGS) -c -o $@ $<, CC $<)

$(out)/libzfs.so: $(libzfs-objects) $(out)/libuutil.so $(out)/libsolaris.so
	$(makedir)
	$(call quiet, $(CC) $(CFLAGS) -o $@ $(libzfs-objects) -L$(out) -luutil, LINK libzfs.so)

#include $(src)/bsd/cddl/contrib/opensolaris/cmd/zpool/build.mk:
zpool-cmd-file-list = zpool_iter  zpool_main  zpool_util  zpool_vdev

zpool-cmd-objects = $(foreach x, $(zpool-cmd-file-list), $(out)/bsd/cddl/contrib/opensolaris/cmd/zpool/$x.o)
zpool-cmd-objects += $(out)/bsd/porting/mnttab.o

cflags-zpool-cmd-includes = $(cflags-libzfs-include) -Ibsd/cddl/contrib/opensolaris/cmd/stat/common

$(zpool-cmd-objects): kernel-defines =

$(zpool-cmd-objects): CFLAGS += -D_GNU_SOURCE

$(zpool-cmd-objects): local-includes += $(cflags-zpool-cmd-includes)

$(zpool-cmd-objects): CFLAGS += -Wno-switch -D__va_list=__builtin_va_list '-DTEXT_DOMAIN=""' \
			-Wno-maybe-uninitialized -Wno-unused-variable -Wno-unknown-pragmas -Wno-unused-function


$(out)/zpool.so: $(zpool-cmd-objects) $(out)/libzfs.so
	$(makedir)
	$(call quiet, $(CC) $(CFLAGS) -o $@ $(zpool-cmd-objects) -L$(out) -lzfs, LINK zpool.so)

#include $(src)/bsd/cddl/contrib/opensolaris/cmd/zfs/build.mk:
zfs-cmd-file-list = zfs_iter zfs_main

zfs-cmd-objects = $(foreach x, $(zfs-cmd-file-list), $(out)/bsd/cddl/contrib/opensolaris/cmd/zfs/$x.o)
zfs-cmd-objects += $(out)/bsd/porting/mnttab.o

cflags-zfs-cmd-includes = $(cflags-libzfs-include)

$(zfs-cmd-objects): kernel-defines =

$(zfs-cmd-objects): CFLAGS += -D_GNU_SOURCE

$(zfs-cmd-objects): local-includes += $(cflags-zfs-cmd-includes)

$(zfs-cmd-objects): CFLAGS += -Wno-switch -D__va_list=__builtin_va_list '-DTEXT_DOMAIN=""' \
			-Wno-maybe-uninitialized -Wno-unused-variable -Wno-unknown-pragmas -Wno-unused-function


$(out)/zfs.so: $(zfs-cmd-objects) $(out)/libzfs.so
	$(makedir)
	$(call quiet, $(CC) $(CFLAGS) -o $@ $(zfs-cmd-objects) -L$(out) -lzfs, LINK zfs.so)
