#!/bin/bash

# ffmpeg-8.1.1 
# 1. Android Paths သတ်မှတ်ခြင်း
export ANDROID_HOME=$HOME/Android/Sdk
export NDK_PATH=$ANDROID_HOME/ndk/$(ls $ANDROID_HOME/ndk | head -n 1)

HOST_TAG="linux-x86_64"
TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/$HOST_TAG"

echo "----------------------------------------"
echo "🚀 Starting FFmpeg Multi-Platform Build..."
echo "----------------------------------------"

OUTPUT_DIR="dist_binaries"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Space အမှားများအားလုံးကို ရှင်းလင်းထားသည်
COMMON_OPTIONS="--enable-gpl \
--enable-nonfree \
--enable-static \
--disable-shared \
--enable-pic \
--disable-asm \
--disable-x86asm \
--enable-debug \
--enable-hwaccels \
--enable-indevs \
--enable-outdevs \
--enable-network \
--enable-decoders \
--enable-encoders \
--enable-demuxers \
--enable-muxers \
--enable-parsers \
--enable-protocols \
--enable-filters"

# ========================================
# 🤖 PART 1: ANDROID BUILDS
# ========================================
ANDROID_ABIS=("arm64-v8a" "armeabi-v7a")

for ABI in "${ANDROID_ABIS[@]}"
do
    echo "========================================"
    echo "📦 Building FFmpeg Android -> $ABI ..."
    echo "========================================"
    
    if [ "$ABI" = "arm64-v8a" ]; then
        API_LEVEL="21"
        COMPILER_ARCH="aarch64-linux-android$API_LEVEL"
        FF_ARCH="aarch64"
        FF_CPU="armv8-a"
    elif [ "$ABI" = "armeabi-v7a" ]; then
        API_LEVEL="24" 
        COMPILER_ARCH="armv7a-linux-androideabi$API_LEVEL"
        FF_ARCH="arm"
        FF_CPU="armv7-a"
    fi

    # Compiler Paths
    export CC="$TOOLCHAIN/bin/$COMPILER_ARCH-clang"
    export CXX="$TOOLCHAIN/bin/$COMPILER_ARCH-clang++"
    export AR="$TOOLCHAIN/bin/llvm-ar"
    export AS="$CC"
    export NM="$TOOLCHAIN/bin/llvm-nm"
    export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
    export STRIP="$TOOLCHAIN/bin/llvm-strip"

    PREFIX_DIR="$(pwd)/build_temp_android_${ABI}"
    rm -rf "$PREFIX_DIR"

    # --cross-prefix ကို ဖြုတ်ပြီး tool များကို တိုက်ရိုက်လမ်းကြောင်းပေးထားသည်
   # --enable-cross-compile ကို ထည့်သွင်းပေးထားပါသည်
    ./configure \
        --prefix="$PREFIX_DIR" \
        --target-os=android \
        --arch="$FF_ARCH" \
        --cpu="$FF_CPU" \
        --enable-cross-compile \
        --cc="$CC" \
        --cxx="$CXX" \
        --ar="$AR" \
        --as="$AS" \
        --nm="$NM" \
        --ranlib="$RANLIB" \
        --strip="$STRIP" \
        --sysroot="$TOOLCHAIN/sysroot" \
        --extra-cflags="-fPIC -O3" \
        --extra-cxxflags="-fPIC -O3" \
        $COMMON_OPTIONS

    if [ $? -eq 0 ]; then
        make clean
        make -j$(nproc)
        make install

        if [ -d "$PREFIX_DIR/lib" ]; then
            mkdir -p "$OUTPUT_DIR/android/$ABI"
            cp -r "$PREFIX_DIR/lib" "$OUTPUT_DIR/android/$ABI/"
            cp -r "$PREFIX_DIR/include" "$OUTPUT_DIR/android/$ABI/"
            echo "✅ Android ($ABI) build done!"
        else
            echo "❌ Android ($ABI) build failed at make stage!"
        fi
    else
        echo "❌ Android ($ABI) configure failed!"
    fi
    rm -rf "$PREFIX_DIR"
done

# ========================================
# 🐧 PART 2: LINUX DESKTOP BUILD (x64)
# ========================================
echo "========================================"
echo "📦 Building FFmpeg Linux Desktop -> x64 ..."
echo "========================================"

unset CC CXX AR AS NM RANLIB STRIP

PREFIX_DIR="$(pwd)/build_temp_linux"
rm -rf "$PREFIX_DIR"

./configure \
    --prefix="$PREFIX_DIR" \
    --extra-cflags="-fPIC -O3" \
    --extra-cxxflags="-fPIC -O3" \
    $COMMON_OPTIONS

if [ $? -eq 0 ]; then
    make clean
    make -j$(nproc)
    make install

    if [ -d "$PREFIX_DIR/lib" ]; then
        mkdir -p "$OUTPUT_DIR/linux_x64"
        cp -r "$PREFIX_DIR/lib" "$OUTPUT_DIR/linux_x64/"
        cp -r "$PREFIX_DIR/include" "$OUTPUT_DIR/linux_x64/"
        echo "✅ Linux (x64) build done!"
    else
        echo "❌ Linux (x64) build failed at make stage!"
    fi
else
    echo "❌ Linux (x64) configure failed!"
fi
rm -rf "$PREFIX_DIR"

echo "----------------------------------------"
echo "🎉 All Platform FFmpeg Binaries Process Completed!"
ls -R "$OUTPUT_DIR" 2>/dev/null || echo "No output generated."
echo "----------------------------------------"
