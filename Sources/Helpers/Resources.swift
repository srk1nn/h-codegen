//
//  Resources.swift
//  h-codegen
//
//  Created by Sorokin Igor on 18.12.2024.
//

import Foundation

enum Resources {

    /// I don't want to create separate Bundle for that, so embedding script into executable
    static let emitObjcHeaderScript = """
    # https://github.com/bevry/dorothy/blob/master/commands/get-arch
    current_arch() {
        local arch
        arch="$(uname -m)" # -i is only linux, -m is linux and apple
        if [[ "$arch" = 'aarch64' || "$arch" = 'arm64' ]]; then
            echo 'a64' # raspberry pi, apple m1
        elif [[ $arch == x86_64* ]]; then
            if [[ "$(uname -a)" == *ARM64* ]]; then
                echo 'a64' # apple m1 running via `arch -x86_64 /bin/bash -c "uname -m"`
            else
                echo 'x64'
            fi
        elif [[ $arch == i*86 ]]; then
            echo 'x32'
        elif [[ $arch == arm* ]]; then
            echo 'a32'
        elif test "$arch" = 'riscv64'; then
            echo 'r64'
        else
            exit 1
        fi
    }
    
    get_xcode_settings() {
        local result
        result=$(grep -w "$1 =" <<< "$XCODE_SETTINGS")
        result=${result//' '}
        result=${result//$1=}
        echo "$result"
    }
    
    prebuild_project() {
        if [[ -n "$XCODE_WORKSPACE" ]]; then
            xcodebuild -workspace $XCODE_WORKSPACE -scheme $XCODE_SCHEME -destination "generic/platform=iOS" -quiet "OTHER_SWIFT_FLAGS=-suppress-warnings" build
        else
            xcodebuild -project $XCODE_PROJECT -scheme $XCODE_SCHEME -destination "generic/platform=iOS" -quiet "OTHER_SWIFT_FLAGS=-suppress-warnings" build
        fi
    }
    
    XCODE_WORKSPACE_KEY="--workspace"
    XCODE_PROJECT_KEY="--project"
    XCODE_SCHEME_KEY="--scheme"
    XCODE_TARGET_KEY="--target"
    SWIFT_SDK_FILES_KEY="--swift-sdk-files"
    CODE_DIRECTORY_KEY="--code-directory"
    TMP_DIRECTORY_KEY="--tmp-directory"
    
    while [[ -n "$1" ]]; do
        case "$1" in
            $XCODE_WORKSPACE_KEY ) XCODE_WORKSPACE=$2
            shift;;
            $XCODE_PROJECT_KEY ) XCODE_PROJECT=$2
            shift;;
            $XCODE_SCHEME_KEY ) XCODE_SCHEME=$2
            shift;;
            $XCODE_TARGET_KEY ) XCODE_TARGET=$2
            shift;;
            $SWIFT_SDK_FILES_KEY ) SWIFT_SDK_FILES=$2
            shift;;
            $CODE_DIRECTORY_KEY ) CODE_DIRECTORY=$2
            shift;;
            $TMP_DIRECTORY_KEY ) TMP_DIRECTORY=$2
            shift;;
        *) echo "[error] Key $1 can't be recognized";;
        esac
        shift
    done
    
    echo "log:Getting the project settings"
    
    if [[ -n "$XCODE_WORKSPACE" ]]; then
        XCODE_SETTINGS=$(xcodebuild -workspace $XCODE_WORKSPACE -scheme $XCODE_SCHEME -destination "generic/platform=iOS Simulator" -showBuildSettings)
    else
        XCODE_SETTINGS=$(xcodebuild -project $XCODE_PROJECT -scheme $XCODE_SCHEME -destination "generic/platform=iOS Simulator" -showBuildSettings)
    fi
    
    PROJ_SYMROOT=$(get_xcode_settings "SYMROOT")
    BUILD_FOLDER=$(ls $PROJ_SYMROOT 2>/dev/null | head -1)
    
    if [[ -z "$BUILD_FOLDER" ]]; then
        echo "log:Incremental builds not found. Prebuilding the project"
        prebuild_project
        BUILD_FOLDER=$(ls $PROJ_SYMROOT | head -1)
    fi
    
    IPHONEOS_DEPLOYMENT_TARGET=$(get_xcode_settings "IPHONEOS_DEPLOYMENT_TARGET")
    PROJ_TEMP_DIR=$(get_xcode_settings "PROJECT_TEMP_DIR")
    PROJ_HEADERS_HMAP="$PROJ_TEMP_DIR/$BUILD_FOLDER/$XCODE_TARGET.build/$XCODE_TARGET-project-headers.hmap"
    
    ARCH=$(current_arch)
    # Если проект собирался с розетой, то скрипт тоже нужно запускать из под розеты
    if [[ "$BUILD_FOLDER" == *"simulator"* && "$ARCH" != "a64" ]]; then
        SWIFTC_SDK=$(xcrun -sdk iphonesimulator --show-sdk-path)
        SWIFTC_TARGET="x86_64-apple-ios$IPHONEOS_DEPLOYMENT_TARGET-simulator"
    else
        SWIFTC_SDK=$(xcrun -sdk iphoneos --show-sdk-path)
        SWIFTC_TARGET="arm64-apple-ios$IPHONEOS_DEPLOYMENT_TARGET"
    fi
    
    echo "log:Emitting -Swift.h file"
    
    swiftc -frontend @"$SWIFT_SDK_FILES" \
        -module-name $XCODE_TARGET \
        -typecheck \
        -sdk "$SWIFTC_SDK" \
        -target "$SWIFTC_TARGET" \
        -I "$CODE_DIRECTORY" \
        -I "$PROJ_SYMROOT/$BUILD_FOLDER" \
        -F "$PROJ_SYMROOT/$BUILD_FOLDER" \
        -Xcc -iquote \
        -Xcc "$PROJ_HEADERS_HMAP" \
        -emit-objc-header-path "$TMP_DIRECTORY/GeneratedSwift.h" \
        -import-underlying-module \
        -suppress-warnings
    
    echo "return:$TMP_DIRECTORY/GeneratedSwift.h"
    """
}
