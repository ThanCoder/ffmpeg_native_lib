# FFmpegNativeLibBindings

Dart FFI bindings for FFmpeg native library (`v8.1.1`). This package provides low-level C API access to FFmpeg components directly within Dart/Flutter projects.

---


## 🌐 Supported Platforms & Architectures

This package currently supports the following platforms:

| OS            | Architecture               | Binary Directory       |   Status    |
| :------------ | :------------------------- | :--------------------- | :---------: |
| 🐧 **Linux**   | `x64` (64-bit Intel/AMD)   | `linux_x64/`           | ✅ Supported |
| 🤖 **Android** | `arm64-v8a` (64-bit ARM)   | `android/arm64-v8a/`   | ✅ Supported |
| 🤖 **Android** | `armeabi-v7a` (32-bit ARM) | `android/armeabi-v7a/` | ✅ Supported |

*Note: For Android, binaries are cross-compiled using Android NDK r28.*

## 🛠️ FFmpeg Build Configuration

This package bundles a custom-compiled version of FFmpeg optimized for size and static linking. Below are the specific compilation flags and enabled features.

### Compilation Parameters
* **FFmpeg Version:** `8.1.1`
* **Optimization:** `-O3` (High optimization)
* **Code Position:** `-fPIC / --enable-pic` (Position Independent Code for Shared Library wrapper)
* **Linking Mode:** `--enable-static --disable-shared` (Statically linked into a single native wrapper)
* **Assembly Optimization:** `--disable-asm --disable-x86asm` (Pure C implementations)

### Supported Components & Features

| Component / Feature       |  Status   | Description                                                                        |
| :------------------------ | :-------: | :--------------------------------------------------------------------------------- |
| **GPL & Nonfree Codecs**  | ✅ Enabled | Supports premium codecs like x264, x265, etc. (`--enable-gpl`, `--enable-nonfree`) |
| **Network Streaming**     | ✅ Enabled | Protocols like HTTP, RTSP, RTMP are supported (`--enable-network`)                 |
| **Hardware Acceleration** | ✅ Enabled | Hardware decoding/encoding hooks are compiled (`--enable-hwaccels`)                |
| **Decoders & Encoders**   | ✅ Enabled | Full support for decoding and encoding video/audio frames                          |
| **Muxers & Demuxers**     | ✅ Enabled | Container formats (MP4, MKV, MOV, MP3) can be read and written                     |
| **Audio/Video Filters**   | ✅ Enabled | Graph filters for video scaling, overlays, and audio resample are available        |
| **Devices (In/Out)**      | ✅ Enabled | Input and output devices support enabled                                           |
| **Debug Symbols**         | ✅ Enabled | Debug mode active for easier native crash analysis (`--enable-debug`)              |

---

## 📦 Bundled Libraries

The bindings expose APIs from the following internal FFmpeg modules:
* `libavutil` (Core utilities)
* `libavcodec` (Audio/Video decoders and encoders)
* `libavformat` (Muxers, demuxers and streaming)
* `libavdevice` (Input/Output devices)
* `libavfilter` (Graph-based frame filtering)
* `libswscale` (Color conversion and video scaling)
* `libswresample` (Audio resampling and rematrixing)

---

## 🚀 How to Regenerate Bindings

If you modify the C headers or wrapper in `src/`, regenerate the Dart FFI code using:

```bash
dart run ffigen --config ffigen.yaml