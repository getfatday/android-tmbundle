#!/bin/bash

# Android.tmbundle build script
# Finds Ant build.xml files and builds the project
# (re)Installs *-debug.apk files to a running Android emulator using adb
#
# Variables
#
# ANDROID_SDK_PATH: Set if you want to specify the Android SDK path
# ANDROID_ACTIVITY_NAME: The name of the activity to launch after install

source "$TM_SUPPORT_PATH/lib/bash_init.sh"
source utilities.sh
source html.sh

(
    export TM_ANT=${TM_ANT:-ant}

    require_cmd "$TM_ANT" "If you have installed ant, then you need to either <a href=\"help:anchor='search_path'%20bookID='TextMate%20Help'\">update your <tt>PATH</tt></a> or set the <tt>TM_ANT</tt> shell variable (e.g. in Preferences / Advanced)"

    export BUILD_DIR="$(project_dir)"
    export MANIFEST="$BUILD_DIR/AndroidManifest.xml"

    require_file "$MANIFEST" "$BUILD_DIR/build.xml"

    if [ -z "$ANDROID_SDK_PATH" ]; then
        require_file "$BUILD_DIR/local.properties"
        export ANDROID_SDK_PATH="$(java_property $BUILD_DIR/local.properties sdk-location)"
    fi
    
    test -z "$ANDROID_SDK_PATH" && \
    put_err "If you have installed the Android SDK, then you need to either <a href=\"help:anchor='search_path'%20bookID='TextMate%20Help'\">update your <tt>PATH</tt></a> or set the <tt>ANDROID_SDK_PATH</tt> shell variable (e.g. in Preferences / Advanced)"

    export ANDROID_SDK_TOOLS="$ANDROID_SDK_PATH/tools"
    export ANDROID_ADB="$ANDROID_SDK_TOOLS/adb"
    export ANDROID_EMULATOR="$ANDROID_SDK_TOOLS/emulator"

    export ANDROID_PACKAGE_NAME="$(package_name $MANIFEST)"
    export ANDROID_ACTIVITY_NAME="${ANDROID_ACTIVITY_NAME:-$(activity_name $MANIFEST)}"

    cd $BUILD_DIR

    export INSTALL_TYPE="$1"
    export DEVICE_COUNT=$(device_count)
    
    if [ $[DEVICE_COUNT] -ne 1 ]; then
        (
            test $[DEVICE_COUNT] -gt 1 && \
            put_err "Too many devices connected!"

            test $[DEVICE_COUNT] -eq 0 && \
            put_line "Waiting for device..." && \
            $ANDROID_ADB wait-for-device

        ) | put_header "Device Bridge"
        
        test $[PIPESTATUS[0]] -ne 0 && \
        exit 1
    fi

    (
        # Determine if package is already installed on device
        test -z "$INSTALL_TYPE" && \
        put_line "Checking device for existing install..." && \
        $ANDROID_ADB shell pm list packages | grep -q "package:$ANDROID_PACKAGE_NAME" && \
        INSTALL_TYPE="reinstall"
    
        $TM_ANT ${INSTALL_TYPE:-install} | put_javac
    
        test $[PIPESTATUS[0]] -ne 0 && \
        put_err "Build Failed!" && \
        exit 1

        put_line "Build Succeeded!"
        test ! -z "$ANDROID_ACTIVITY_NAME" && ( \
            put_line "Launching $ANDROID_PACKAGE_NAME/$ANDROID_ACTIVITY_NAME"; \
            $ANDROID_ADB shell am start -n $ANDROID_PACKAGE_NAME/$ANDROID_ACTIVITY_NAME > /dev/null \
        )
        
        test ! -z "$(ps -A | grep emulator | grep -v grep)" && \
        osascript -e "tell application \"$(which $ANDROID_EMULATOR)\" to activate" 2> /dev/null

    ) | put_header "Building $ANDROID_PACKAGE_NAME"

) | put_window "Android: Building $ANDROID_PACKAGE_NAME"
