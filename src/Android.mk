# Copyright (C) 2011 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH := $(call my-dir)

define pcsc-transform-variables
@mkdir -p $(dir $@)
@echo "Sed: $(if $(PRIVATE_MODULE),$(PRIVATE_MODULE),$@) <= $<"
$(hide) sed $(foreach var,$(REPLACE_VARS),\
  -e "s/@$(var)@/$(subst /,\/,$(PCSC_$(var)))/g") $< >$@
endef

define pcsc-transform-file
$(1): REPLACE_VARS := $(2)
$(1): $$(strip $(1)).in
	$$(pcsc-transform-variables)
endef

PCSC_VERSION := 1.8.8
PCSC_PCSCLITE_CONFIG_DIR := /system/etc/reader.conf.d

$(eval $(call pcsc-transform-file,$(LOCAL_PATH)/PCSC/pcsclite.h,VERSION))
$(eval $(call pcsc-transform-file,$(LOCAL_PATH)/pcscd.h,VERSION PCSCLITE_CONFIG_DIR))

define pcsc-generate-config-h
@mkdir -p $(dir $@)
@echo "Generate: $(PRIVATE_MODULE) <= $@"
@echo "/* config.h.in.  Generated automatically from configure.in by Android.mk */" > $@
$(hide) $(foreach var,$(REPLACE_VARS),\
  echo "#define $(var) $(if $(filter HAVE_%,$(var)),1,\
    $(if $(filter 1,$(PCSC_$(var))),1,\"$(PCSC_$(var))\"))" >> $@;)
endef

PCSC_LSTAT_FOLLOWS_SLASHED_SYMLINK := 1
PCSC_PACKAGE := pcsc-lite
PCSC_PACKAGE_BUGREPORT :=
PCSC_PACKAGE_NAME := pcsc-lite
PCSC_PACKAGE_STRING := $(PCSC_PACKAGE_NAME) $(PCSC_VERSION)
PCSC_PACKAGE_URL := $(PCSC_PACKAGE)
PCSC_PACKAGE_VERSION := $(PCSC_VERSION)
PCSC_PCSCD_BINARY := /system/bin/pcscd
PCSC_PCSCLITE_HP_DROPDIR := /system/lib/pcsc/drivers
PCSC_PCSC_ARCH := Linux
PCSC_STDC_HEADERS := 1
PCSC_TIME_WITH_SYS_TIME := 1
PCSC_USE_IPCDIR := /data/run/pcscd
PCSC_USE_SERIAL := 1
PCSC_PCSCLITE_FEATURES := \
  Linux \
  $(TARGET_ARCH)-android-$(TARGET_OS)-gnu \
  $(if $(filter 1,$(PCSC_USE_SERIAL)),serial) \
  ipcdir=$(PCSC_USE_IPCDIR) \
  configdir=$(PCSC_PCSCLITE_CONFIG_DIR) \
  $(NULL)
pcsc_config_vars := \
  HAVE_DAEMON \
  HAVE_DLFCN_H \
  HAVE_FCNTL_H \
  HAVE_FLOCK \
  HAVE_GETOPT_H \
  HAVE_GETOPT_LONG \
  HAVE_INTTYPES_H \
  HAVE_MEMORY_H \
  HAVE_NANOSLEEP \
  HAVE_PTHREAD \
  HAVE_STDLIB_H \
  HAVE_STRERROR \
  HAVE_STRINGS_H \
  HAVE_STRING_H \
  HAVE_STRLCAT \
  HAVE_STRLCPY \
  HAVE_SYSLOG_H \
  HAVE_SYS_STAT_H \
  HAVE_SYS_TYPES_H \
  HAVE_SYS_WAIT_H \
  HAVE_UNISTD_H \
  HAVE_VPRINTF \
  HAVE_VSNPRINTF \
  LSTAT_FOLLOWS_SLASHED_SYMLINK \
  $(if $(filter user,$(TARGET_BUILD_VARIANT)),NO_LOG) \
  PACKAGE \
  PACKAGE_BUGREPORT \
  PACKAGE_NAME \
  PACKAGE_STRING \
  PACKAGE_URL \
  PACKAGE_VERSION \
  PCSCD_BINARY \
  PCSCLITE_FEATURES \
  PCSCLITE_HP_DROPDIR \
  PCSC_ARCH \
  STDC_HEADERS \
  TIME_WITH_SYS_TIME \
  USE_IPCDIR \
  USE_SERIAL \
  VERSION \
  $(NULL)
# AC_APPLE_UNIVERSAL_BUILD
# ATR_DEBUG
# HAVE_DL_H
# HAVE_DOPRNT
# HAVE_LIBUDEV
# HAVE_LIBUSB_H
# HAVE_MQUEUE_H
# HAVE_PTHREAD_CANCEL
# HAVE_PTHREAD_PRIO_INHERIT
# HAVE_STAT_EMPTY_STRING_BUG
# HAVE_STDINT_H
# HAVE_STPCPY
# HAVE_SYS_FILIO_H
# USE_USB
$(LOCAL_PATH)/config.h: REPLACE_VARS := $(pcsc_config_vars)
$(LOCAL_PATH)/config.h:
	$(pcsc-generate-config-h)

include $(CLEAR_VARS)
LOCAL_MODULE := libpcsclite
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := \
  debug.c \
  error.c \
  winscard_clnt.c \
  simclist.c \
  strlcat.c \
  strlcpy.c \
  sys_unix.c \
  utils.c \
  winscard_msg.c \
  $(NULL)
LOCAL_COPY_HEADERS_TO := PCSC
LOCAL_COPY_HEADERS := \
  $(LOCAL_COPY_HEADERS_TO)/pcsclite.h \
  $(NULL)
LOCAL_GENERATED_SOURCES := \
  $(LOCAL_PATH)/PCSC/pcsclite.h \
  $(LOCAL_PATH)/config.h \
  $(NULL)
LOCAL_CFLAGS := \
  -DLIBPCSCLITE \
  -DSIMCLIST_NO_DUMPRESTORE \
  $(NULL)
LOCAL_C_INCLUDES := \
  $(LOCAL_PATH)/PCSC \
  $(NULL)
include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := pcscd
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := \
  atrhandler.c \
  atrhandler.h \
  configfile.h \
  debuglog.c \
  dyn_generic.h \
  dyn_hpux.c \
  dyn_macosx.c \
  dyn_unix.c \
  eventhandler.c \
  eventhandler.h \
  hotplug_generic.c \
  hotplug.h \
  ifdwrapper.c \
  ifdwrapper.h \
  misc.h \
  parser.h \
  pcscdaemon.c \
  PCSC/debuglog.h \
  PCSC/ifdhandler.h \
  PCSC/pcsclite.h \
  PCSC/winscard.h \
  PCSC/wintypes.h \
  powermgt_generic.c \
  powermgt_generic.h \
  prothandler.c \
  prothandler.h \
  readerfactory.c \
  readerfactory.h \
  sd-daemon.c \
  sd-daemon.h \
  simclist.c \
  simclist.h \
  strlcat.c \
  strlcpy.c \
  strlcpycat.h \
  sys_generic.h \
  sys_unix.c \
  utils.c \
  utils.h \
  winscard.c \
  winscard_msg.c \
  winscard_msg.h \
  winscard_msg_srv.c \
  winscard_svc.c \
  winscard_svc.h \
  $(if $(filter USE_SERIAL,$(pcsc_config_vars)), configfile.l) \
  $(NULL)
LOCAL_GENERATED_SOURCES := \
  $(LOCAL_PATH)/config.h \
  $(LOCAL_PATH)/pcscd.h \
  $(NULL)
LOCAL_CFLAGS := \
  -DPCSCD \
  -DSIMCLIST_NO_DUMPRESTORE \
  $(NULL)
LOCAL_C_INCLUDES := \
  $(LOCAL_PATH)/PCSC \
  $(NULL)
LOCAL_SHARED_LIBRARIES := \
  libdl \
  libpcsclite \
  $(NULL)
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_MODULE := testpcsc
LOCAL_MODULE_TAGS := tests
LOCAL_SRC_FILES := \
  testpcsc.c \
  $(NULL)
LOCAL_C_INCLUDES := \
  $(LOCAL_PATH)/PCSC \
  $(NULL)
LOCAL_SHARED_LIBRARIES := \
  libpcsclite \
  $(NULL)
include $(BUILD_EXECUTABLE)
