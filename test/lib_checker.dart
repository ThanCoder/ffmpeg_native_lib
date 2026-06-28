// ignore_for_file: unused_import, avoid_print

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ffmpeg_native_lib/ffmpeg_native_lib_bindings_generated.dart';

void main() async {
  print('av_version_info: ${av_version_info().cast<Utf8>().toDartString()}');
  print('avutil_version: ${avutil_version()}');
  print('avcodec_version: ${avcodec_version()}');
  print('swscale_version: ${swscale_version()}');
  print('avdevice_version: ${avdevice_version()}');
  print('avfilter_version: ${avfilter_version()}');
  print('avformat_version: ${avformat_version()}');
  print('swresample_version: ${swresample_version()}');
  print('avutil_configuration: ${avutil_configuration().cast<Utf8>().toDartString()}');
  print('swresample_configuration: ${swresample_configuration().cast<Utf8>().toDartString()}');
  print('avcodec_configuration: ${avcodec_configuration().cast<Utf8>().toDartString()}');
  print('swscale_configuration: ${swscale_configuration().cast<Utf8>().toDartString()}');
  print('avdevice_configuration: ${avdevice_configuration().cast<Utf8>().toDartString()}');
  print('avfilter_configuration: ${avfilter_configuration().cast<Utf8>().toDartString()}');
  print('avformat_configuration: ${avformat_configuration().cast<Utf8>().toDartString()}');
}
