// encoding=utf-8
PRODUCT_NAME=XcodeSwitcherMenuBarExtra
PRODUCT_EXTENSION=app
BUILD_PATH=build
ARCHIVE_PATH=archive.xcarchive
EXPORT_PATH=export
DEPLOYMENT=Release
APP_BUNDLE=$(PRODUCT_NAME).$(PRODUCT_EXTENSION)
APP=$(BUILD_PATH)/$(DEPLOYMENT)/$(APP_BUNDLE)
APP_NAME=$(BUILD_PATH)/$(DEPLOYMENT)/$(PRODUCT_NAME)
TARGET=XcodeSwitcherMenuBarExtra
INFO_PLIST=XcodeSwitcherMenuBarExtra/Info.plist

XCODEBUILD=$(shell xcrun -f xcodebuild)

VER_CMD=grep -A1 'CFBundleShortVersionString' $(INFO_PLIST) | tail -1 | tr -d "'\t</string>" 
VERSION=$(shell $(VER_CMD))

all: package

HELPER_NAME=XcodeSwitcherMenuBarHelper
HELPER_INFO_PLIST=$(HELPER_NAME)/Helper-Info.plist
JOBBLESS_PY=$(HELPER_NAME)/SMJobBlessUtil.py
JOBBLESS_CONFIGURATION=Debug


CheckJobBless:
	SMAC=`/usr/libexec/PlistBuddy -c "print :SMAuthorizedClients" $(HELPER_INFO_PLIST)`; \
	SMPE=`/usr/libexec/PlistBuddy -c "print :SMPrivilegedExecutables:com.masakih.XcodeSwitcherMenuBarHelper" $(INFO_PLIST)`; \
	if [ -z "$${SMAC}" -o -z "$${SMPE}" ]; then \
	  make JobBless; \
	fi

JobBless:
	$(XCODEBUILD) \
	  -derivedDataPath=$(BUILD_PATH) \
	  -configuration $(JOBBLESS_CONFIGURATION) \
	  -target $(TARGET)
	$(JOBBLESS_PY) setreq \
	  $(BUILD_PATH)/$(JOBBLESS_CONFIGURATION)/$(APP_BUNDLE) \
	  $(INFO_PLIST) \
	  $(HELPER_INFO_PLIST)

ClearJobBless:
	/usr/libexec/PlistBuddy -c "delete :SMAuthorizedClients" $(HELPER_INFO_PLIST)
	/usr/libexec/PlistBuddy -c "delete :SMPrivilegedExecutables" $(INFO_PLIST)

uninstll-helper:
	sudo rm /Library/PrivilegedHelperTools/com.masakih.XcodeSwitcherMenubarHelper
	sudo rm /Library/LaunchDaemons/com.masakih.XcodeSwitcherMenubarHelper.plist

deploy:
	test -z "`git status --porcelain`"

$(ARCHIVE_PATH): CheckJobBless
	$(XCODEBUILD) archive \
	  -derivedDataPath=$(BUILD_PATH) \
	  -configuration $(DEPLOYMENT) \
	  -scheme $(TARGET) \
	  -archivePath $(ARCHIVE_PATH) \
	  CURRENT_PROJECT_VERSION=`git rev-parse --short HEAD`

exportArchive: $(ARCHIVE_PATH)
	xcodebuild \
	  -exportArchive \
	  -archivePath $(ARCHIVE_PATH) \
	  -exportOptionsPlist ExportOptions.plist

notarize: exportArchive
	until xcodebuild \
	  -exportNotarizedApp \
	  -archivePath $(ARCHIVE_PATH) \
	  -exportPath $(EXPORT_PATH); \
	do \
	  echo wait 10s...; \
	  sleep 10; \
	done

claen: ClearJobBless
	rm -fr $(BUILD_PATH)
	rm -fr $(ARCHIVE_PATH)
	rm -fr $(EXPORT_PATH)


package: deploy release
	REV=`git rev-parse --short HEAD`; \
	ditto -ck -rsrc --keepParent $(APP) $(APP_NAME)-$(VERSION)-$${REV}.zip

Localizable: $(LOCALIZE_FILES)
	(cd XcodeSwitcherMenuBarExtra; ${MAKE} $@;)

checkLocalizable:
	(cd XcodeSwitcherMenuBarExtra; ${MAKE} $@;)
