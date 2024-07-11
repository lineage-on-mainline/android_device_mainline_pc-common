#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from mainline/common
include device/mainline/common/BoardConfigMainlineCommon.mk

COMMON_PATH := device/mainline/pc-common

# A/B
AB_OTA_UPDATER := false

# Graphics
BOARD_MESA3D_GALLIUM_DRIVERS += \
    crocus \
    etnaviv \
    freedreno \
    i915 \
    iris \
    lima \
    nouveau \
    r300 \
    r600 \
    radeonsi \
    softpipe \
    svga \
    tegra \
    v3d \
    vc4 \
    virgl \
    zink

# Disabled drivers:
# - asahi: src/asahi/clc/meson.build:7:19: ERROR: Tried to mix a host machine library
#          ("asahi_compiler") with a build machine target "asahi_clc" This is not possible in a
#          cross build.
# - d3d12: Requires DirectX-Guids
# - llvmpipe: Enabled automatically with mainline/common if available
# - panfrost: src/panfrost/clc/meson.build:9:26: ERROR: Tried to mix a host machine library
#             ("panfrost_bifrost") with a build machine target "panfrost_compile" This is not
#             possible in a cross build.

# Kernel
BOARD_KERNEL_BASE ?= 0x00000000
BOARD_KERNEL_PAGESIZE ?= 4096
BOARD_KERNEL_CMDLINE := loop.max_part=7
BOARD_KERNEL_CMDLINE += androidboot.hardware=pc
BOARD_KERNEL_CMDLINE += androidboot.boot_devices=any
BOARD_KERNEL_CMDLINE += androidboot.init_fatal_reboot_target=recovery
BOARD_KERNEL_CMDLINE += androidboot.first_stage_console=2
BOARD_KERNEL_CMDLINE += androidboot.console=tty0
BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive
BOARD_KERNEL_IMAGE_NAME ?= Image
BOARD_USES_GENERIC_KERNEL_IMAGE := true
TARGET_KERNEL_SOURCE := kernel/google/android16-6.12
TARGET_KERNEL_CONFIG += gki_defconfig
TARGET_KERNEL_CONFIG_EXT += $(COMMON_PATH)/kconfigs/pc_gki.config

# Kernel modules
RECOVERY_KERNEL_MODULES := $(strip $(shell cat $(COMMON_PATH)/modprobe/modules.include.recovery))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(COMMON_PATH)/modprobe/modules.load.recovery))

BOOT_KERNEL_MODULES := $(strip $(shell cat $(COMMON_PATH)/modprobe/modules.include.initramfs))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(COMMON_PATH)/modprobe/modules.load.initramfs))

#BOARD_VENDOR_KERNEL_MODULES := $(strip $(shell cat $(COMMON_PATH)/modprobe/modules.include.vendor))
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(COMMON_PATH)/modprobe/modules.load.vendor))

SYSTEM_KERNEL_MODULES := $(strip $(shell cat $(COMMON_PATH)/modprobe/modules.include.system))
BOARD_SYSTEM_KERNEL_MODULES_LOAD := $(strip $(shell cat $(COMMON_PATH)/modprobe/modules.load.system))

# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144 # (BOARD_KERNEL_PAGESIZE * 64)
BOARD_BOOTIMAGE_PARTITION_SIZE := 134217728
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 134217728
BOARD_CACHEIMAGE_PARTITION_SIZE := 402653184
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_USERDATAIMAGE_PARTITION_SIZE := 5209325568
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_USES_METADATA_PARTITION := true

SSI_PARTITIONS := product system system_ext
TREBLE_PARTITIONS := odm odm_dlkm system_dlkm vendor vendor_dlkm
ALL_PARTITIONS := $(SSI_PARTITIONS) $(TREBLE_PARTITIONS)

$(foreach p, $(call to-upper, $(SSI_PARTITIONS)), \
    $(eval BOARD_$(p)IMAGE_FILE_SYSTEM_TYPE := ext4))

$(foreach p, $(call to-upper, $(TREBLE_PARTITIONS)), \
    $(eval BOARD_$(p)IMAGE_FILE_SYSTEM_TYPE := erofs))

$(foreach p, $(call to-upper, $(ALL_PARTITIONS)), \
    $(eval TARGET_COPY_OUT_$(p) := $(call to-lower, $(p))))

# Partitions - dynamic
BOARD_SUPER_PARTITION_SIZE ?= 12884901888 # 12GiB
BOARD_SUPER_PARTITION_GROUPS := pc_dynamic_partitions
BOARD_PC_DYNAMIC_PARTITIONS_PARTITION_LIST := $(ALL_PARTITIONS)
BOARD_PC_DYNAMIC_PARTITIONS_SIZE := 12880707584 # (BOARD_SUPER_PARTITION_SIZE - 4MiB)

# Platform
TARGET_BOARD_PLATFORM := pc

# Properties
TARGET_VENDOR_PROP += $(COMMON_PATH)/properties/vendor.prop

# Recovery
TARGET_RECOVERY_FSTAB := $(COMMON_PATH)/init/etc/fstab.pc
TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# VINTF
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(COMMON_PATH)/vintf/framework_compatibility_matrix.xml
DEVICE_MANIFEST_FILE += $(COMMON_PATH)/vintf/manifest.xml
