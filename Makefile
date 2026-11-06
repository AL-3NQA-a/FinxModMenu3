TARGET := iphone:clang:latest:14.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := FinxModMenu3

FinxModMenu3_FILES = Tweak.xm
FinxModMenu3_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/usr/lib
	cp $(THEOS_OBJ_DIR)/FinxModMenu3.dylib ./FinxModMenu3.dylib
