// ignore_for_file: non_constant_identifier_names

import 'package:ffi/ffi.dart';
import 'package:ffmpeg_native_lib/ffmpeg_native_lib_bindings_generated.dart';

export 'ffmpeg_native_lib_bindings_generated.dart';

//*******************Version******************** */
String get avVersionInfo => av_version_info().cast<Utf8>().toDartString();
int get avutilVersion => avutil_version();
int get avcodecVersion => avcodec_version();
int get swscaleVersion => swscale_version();
int get avdeviceVersion => avdevice_version();
int get avfilterVersion => avfilter_version();
int get avformatVersion => avformat_version();
int get swresampleVersion => swresample_version();

//*******************Configuration******************** */
String get avutilConfiguration =>
    avutil_configuration().cast<Utf8>().toDartString();
String get swresampleConfiguration =>
    swresample_configuration().cast<Utf8>().toDartString();
String get avcodecConfiguration =>
    avcodec_configuration().cast<Utf8>().toDartString();
String get swscaleConfiguration =>
    swscale_configuration().cast<Utf8>().toDartString();
String get avdeviceConfiguration =>
    avdevice_configuration().cast<Utf8>().toDartString();
String get avfilterConfiguration =>
    avfilter_configuration().cast<Utf8>().toDartString();
String get avformatConfiguration =>
    avformat_configuration().cast<Utf8>().toDartString();
