#!/bin/bash

BASE_DIR="/home/thancoder/source_to_static_lib/ffmpeg-8.1.1/dist_binaries"
export ANDROID_HOME=$HOME/Android/Sdk
export NDK_PATH=$ANDROID_HOME/ndk/$(ls $ANDROID_HOME/ndk | head -n 1)

HOST_TAG="linux-x86_64"
TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/$HOST_TAG"

LIBS=(
    "libavdevice.a"
    "libavfilter.a"
    "libavformat.a"
    "libavcodec.a"
    "libswresample.a"
    "libswscale.a"
    "libavutil.a"
)

echo "----------------------------------------"
echo "🌀 Starting Multi-Platform .a to .so Conversion (7 Libs)..."
echo "----------------------------------------"

# ========================================
# 🤖 PART 1: ANDROID BUILDS (.so)
# ========================================
ANDROID_ABIS=("arm64-v8a" "armeabi-v7a")

for ABI in "${ANDROID_ABIS[@]}"
do
    TARGET_DIR="$BASE_DIR/android/$ABI"
    
    if [ ! -d "$TARGET_DIR" ]; then
        echo "⚠️  Android Directory not found for $ABI, skipping..."
        continue
    fi

    echo "📦 Processing Android -> $ABI ..."

    if [ "$ABI" = "arm64-v8a" ]; then
        API_LEVEL="26"
        CLANG_TARGET="aarch64-linux-android"
        LDFLAGS="-Wl,-Bsymbolic"
        NDK_LIB_DIR="$TOOLCHAIN/sysroot/usr/lib/aarch64-linux-android/$API_LEVEL"
    elif [ "$ABI" = "armeabi-v7a" ]; then
        API_LEVEL="26"
        CLANG_TARGET="armv7a-linux-androideabi"
        LDFLAGS="-Wl,--fix-cortex-a8 -Wl,-Bsymbolic"
        NDK_LIB_DIR="$TOOLCHAIN/sysroot/usr/lib/arm-linux-androideabi/$API_LEVEL"
    fi

    CC="$TOOLCHAIN/bin/${CLANG_TARGET}${API_LEVEL}-clang"
    STRIP="$TOOLCHAIN/bin/llvm-strip"

    LIB_PATHS=()
    MISSING_LIB=0
    for LIB in "${LIBS[@]}"; do
        if [ -f "$TARGET_DIR/lib/$LIB" ]; then
            LIB_PATHS+=("$TARGET_DIR/lib/$LIB")
        elif [ -f "$TARGET_DIR/$LIB" ]; then
            LIB_PATHS+=("$TARGET_DIR/$LIB")
        else
            echo "❌ Missing: $LIB in $TARGET_DIR"
            MISSING_LIB=1
        fi
    done

    if [ $MISSING_LIB -eq 1 ]; then
        echo "❌ Skipped $ABI due to missing libraries."
        continue
    fi

    # ⚡ -lcamera2ndk ကို ထပ်မံဖြည့်စွက်ပြီး ကင်မရာ error ကို အပြီးသတ်ရှင်းလင်းခြင်း
    $CC -shared -target ${CLANG_TARGET}${API_LEVEL} \
        --sysroot="$TOOLCHAIN/sysroot" \
        -L"$NDK_LIB_DIR" \
        $LDFLAGS \
        -Wl,--gc-sections \
        -Wl,--no-undefined \
        -Wl,-z,noexecstack \
        -o "$TARGET_DIR/libffmpeg.so" \
        -Wl,--whole-archive \
        "${LIB_PATHS[@]}" \
        -Wl,--no-whole-archive \
        -lm -lz -ldl -llog -lmediandk -lnativewindow -lcamera2ndk

    if [ $? -eq 0 ]; then
        $STRIP --strip-unneeded "$TARGET_DIR/libffmpeg.so"
        echo "✅ Created Android ($ABI): $TARGET_DIR/libffmpeg.so"
    else
        echo "❌ Linking failed for Android $ABI"
    fi
    echo "----------------------------------------"
done


# ========================================
# 🐧 PART 2: LINUX DESKTOP BUILD (x64 .so)
# ========================================
LINUX_DIR="$BASE_DIR/linux_x64"

if [ -d "$LINUX_DIR" ]; then
    echo "📦 Processing Linux Desktop -> x64 ..."

    LINUX_LIB_PATHS=()
    LINUX_MISSING=0
    for LIB in "${LIBS[@]}"; do
        if [ -f "$LINUX_DIR/lib/$LIB" ]; then
            LINUX_LIB_PATHS+=("$LINUX_DIR/lib/$LIB")
        elif [ -f "$LINUX_DIR/$LIB" ]; then
            LINUX_LIB_PATHS+=("$LINUX_DIR/$LIB")
        else
            echo "❌ Missing: $LIB in $LINUX_DIR"
            LINUX_MISSING=1
        fi
    done

    if [ $LINUX_MISSING -eq 0 ]; then
        gcc -shared -Wl,--soname,libffmpeg.so \
            -Wl,--gc-sections \
            -Wl,-Bsymbolic \
            -o "$LINUX_DIR/libffmpeg.so" \
            -Wl,--whole-archive \
            "${LINUX_LIB_PATHS[@]}" \
            -Wl,--no-whole-archive \
            -lm -lz -ldl -lpthread -lrt

        if [ $? -eq 0 ]; then
            strip --strip-unneeded "$LINUX_DIR/libffmpeg.so"
            echo "✅ Created Linux (x64): $LINUX_DIR/libffmpeg.so"
        else
            echo "❌ Linking failed for Linux (x64)"
        fi
    else
        echo "❌ Skipped Linux (x64) due to missing libraries."
    fi
else
    echo "⚠️  Linux Directory not found at $LINUX_DIR, skipping..."
fi

echo "----------------------------------------"
echo "🎉 All Platforms Completed!"
