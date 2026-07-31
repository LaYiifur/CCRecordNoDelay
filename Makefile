ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

THEOS_PACKAGE_SCHEME = rootless
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CCRecordNoDelay

CCRecordNoDelay_FILES = Tweak.x
CCRecordNoDelay_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
THEOS_PACKAGE_DIR = /var/mobile/Documents/theos_debs