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

all: $(out)/loader.img links $(out)/zfs_builder-stripped.elf
ifeq ($(arch),x64)
all: $(out)/vmlinuz.bin
endif
ifeq ($(arch),aarch64)
all: $(out)/zfs_builder.img
endif

builder_edata = $(shell readelf --syms $(out)/zfs_builder.elf | grep "\.edata" | awk '{print "0x" $$2}')
builder_image_size = $$(( $(builder_edata) - $(kernel_vm_base) ))

$(out)/zfs_builder.img: $(out)/preboot.bin $(out)/zfs_builder-stripped.elf
	$(call quiet, dd if=$(out)/preboot.bin of=$@ > /dev/null 2>&1, DD $@ preboot.bin)
	$(call quiet, dd if=$(out)/zfs_builder-stripped.elf of=$@ conv=notrunc obs=4096 seek=16 > /dev/null 2>&1, DD $@ zfs_builder-stripped.elf)
	$(call quiet, scripts/imgedit.py setsize_aarch64 "-f raw $@" $(builder_image_size), IMGEDIT $@)
	$(call quiet, scripts/imgedit.py setargs "-f raw $@" $(cmdline), IMGEDIT $@)

$(out)/bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/metaslab.o: COMMON+=-Wno-tautological-compare

zfs += bsd/sys/cddl/contrib/opensolaris/common/zfs/zfeature_common.o
zfs += bsd/sys/cddl/contrib/opensolaris/common/zfs/zfs_comutil.o
zfs += bsd/sys/cddl/contrib/opensolaris/common/zfs/zfs_deleg.o
zfs += bsd/sys/cddl/contrib/opensolaris/common/zfs/zfs_fletcher.o
zfs += bsd/sys/cddl/contrib/opensolaris/common/zfs/zfs_ioctl_compat.o
zfs += bsd/sys/cddl/contrib/opensolaris/common/zfs/zfs_namecheck.o
zfs += bsd/sys/cddl/contrib/opensolaris/common/zfs/zfs_prop.o
zfs += bsd/sys/cddl/contrib/opensolaris/common/zfs/zpool_prop.o
zfs += bsd/sys/cddl/contrib/opensolaris/common/zfs/zprop_common.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/arc.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/bplist.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/bpobj.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/bptree.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dbuf.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/ddt.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/ddt_zap.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dmu.o
#zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dmu_diff.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dmu_object.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dmu_objset.o
#zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dmu_send.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dmu_traverse.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dmu_tx.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dmu_zfetch.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dnode.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dnode_sync.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dsl_dataset.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dsl_deadlist.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dsl_deleg.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dsl_dir.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dsl_pool.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dsl_prop.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dsl_scan.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/dsl_synctask.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/gzip.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/lzjb.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/metaslab.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/refcount.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/rrwlock.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/sa.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/sha256.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/spa.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/space_map.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/spa_config.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/spa_errlog.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/spa_history.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/spa_misc.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/txg.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/uberblock.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/unique.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/vdev.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/vdev_cache.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/vdev_disk.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/vdev_file.o
#zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/vdev_geom.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/vdev_label.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/vdev_mirror.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/vdev_missing.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/vdev_queue.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/vdev_raidz.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/vdev_root.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zap.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zap_leaf.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zap_micro.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfeature.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_acl.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_byteswap.o
#zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_ctldir.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_debug.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_dir.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_fm.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_fuid.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_ioctl.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_init.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_log.o
#zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_onexit.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_replay.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_rlock.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_sa.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_vfsops.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_vnops.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zfs_znode.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zil.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zio.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zio_checksum.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zio_compress.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zio_inject.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zle.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zrlock.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/zvol.o
zfs += bsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs/lz4.o

solaris += $(zfs)

$(zfs:%=$(out)/%): CFLAGS+= \
	-DBUILDING_ZFS \
	-Wno-array-bounds \
	-Ibsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs \
	-Ibsd/sys/cddl/contrib/opensolaris/common/zfs

drivers += drivers/zfs.o
fs_objs += zfs/zfs_null_vfsops.o

$(out)/zfs_builder.elf: $(stage1_targets) arch/$(arch)/loader.ld $(out)/zfs_builder_bootfs.o $(loader_options_dep) $(version_script_file)
	$(call quiet, $(LD) -o $@ $(def_symbols) \
		-Bdynamic --export-dynamic --eh-frame-hdr --enable-new-dtags -L$(out)/arch/$(arch) \
            $(patsubst %version_script,--version-script=%version_script,$(patsubst %.ld,-T %.ld,$^)) \
	    $(linker_archives_options) $(conf_linker_extra_options), \
		LINK zfs_builder.elf)
$(out)/zfs_builder-stripped.elf:  $(out)/zfs_builder.elf
	$(call quiet, $(STRIP) $(out)/zfs_builder.elf -o $(out)/zfs_builder-stripped.elf, STRIP zfs_builder.elf -> zfs_builder-stripped.elf )

$(shell mkdir -p $(out) && cp zfs_builder_bootfs.manifest.skel $(out)/zfs_builder_bootfs.manifest)
ifeq ($(conf_hide_symbols),1)
$(shell echo "/usr/lib/libstdc++.so.6: $$(readlink -f $(libstd_dir))/libstdc++.so" >> $(out)/zfs_builder_bootfs.manifest)
endif

$(out)/zfs_builder_bootfs.o: $(out)/zfs_builder_bootfs.bin
$(out)/zfs_builder_bootfs.o: ASFLAGS += -I$(out)

$(out)/tools/mkfs/mkfs.so: $(out)/tools/mkfs/mkfs.o $(out)/libzfs.so
	$(makedir)
	$(call quiet, $(CXX) $(CXXFLAGS) -o $@ $(out)/tools/mkfs/mkfs.o $(LDFLAGS) -L$(out) -lzfs, LINK mkfs.so)

$(out)/tools/cpiod/cpiod.so: $(out)/tools/cpiod/cpiod.o $(out)/tools/cpiod/cpio.o $(out)/tools/cpiod/options.o $(out)/libzfs.so
	$(makedir)
	$(call quiet, $(CXX) $(CXXFLAGS) -o $@ $(out)/tools/cpiod/cpiod.o $(out)/tools/cpiod/cpio.o $(out)/tools/cpiod/options.o $(LDFLAGS) -L$(out) -lzfs, LINK cpiod.so)

libzfs-file-list = changelist config dataset diff import iter mount pool status util
libzfs-objects = $(foreach file, $(libzfs-file-list), $(out)/bsd/cddl/contrib/opensolaris/lib/libzfs/common/libzfs_$(file).o)

$(out)/fs/zfs/zfs_initialize.o: CFLAGS+= \
	-DBUILDING_ZFS \
	-Ibsd/sys/cddl/contrib/opensolaris/uts/common/fs/zfs \
	-Ibsd/sys/cddl/contrib/opensolaris/common/zfs \
	-Ibsd/sys/cddl/compat/opensolaris \
	-Ibsd/sys/cddl/contrib/opensolaris/common \
	-Ibsd/sys/cddl/contrib/opensolaris/uts/common \
	-Ibsd/sys \
	-Wno-array-bounds \
	-fno-strict-aliasing \
	-Wno-unknown-pragmas \
	-Wno-unused-variable \
	-Wno-switch \
	-Wno-maybe-uninitialized

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
