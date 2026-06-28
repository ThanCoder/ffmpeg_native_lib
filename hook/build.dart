// ignore_for_file: avoid_print

import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:path/path.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final targetOS = input.config.code.targetOS;
    final targetArchitecture = input.config.code.targetArchitecture;
    final cacheLibPath = join(
      input.packageRoot.toFilePath(),
      '.dart_tool',
      'native_assets',
    );

    final libFile = await ensureLibPath(
      cacheLibPath,
      targetOS,
      targetArchitecture,
    );

    output.assets.code.add(
      CodeAsset(
        package: packageName,
        name: '${packageName}_bindings_generated.dart',
        linkMode: DynamicLoadingBundled(),
        file: libFile.uri,
      ),
    );
  });
}

Future<File> ensureLibPath(
  String rootDir,
  OS targetOS,
  Architecture targetArchitecture, {
  bool isLocalTest = false,
}) async {
  final libName = 'libffmpeg.so';

  final subLibDirname = switch (targetOS) {
    .linux => 'linux',
    .android => join('android', targetArchitecture.name),
    _ => '',
  };
  final subLibDir = Directory(join(rootDir, subLibDirname));
  if (!subLibDir.existsSync()) {
    subLibDir.createSync(recursive: true);
  }

  File libFile = File(join(subLibDir.path, libName));
  // lib file ရှိနေရင် ပြန်ပေးလိုက်မယ်
  if (libFile.existsSync()) {
    return libFile;
  }
  bool isSupported = false;

  if (isLocalTest) {
    // local
    if (targetOS == .linux) {
      final inpF = File(
        '/home/thancoder/source_to_static_lib/ffmpeg-8.1.1/dist_binaries/linux_x64/$libName',
      );
      libFile.writeAsBytesSync(inpF.readAsBytesSync());
      isSupported = true;
    }
    if (targetOS == .android) {
      if (targetArchitecture == .arm) {
        final inpF = File(
          '/home/thancoder/source_to_static_lib/ffmpeg-8.1.1/dist_binaries/android/armeabi-v7a/$libName',
        );
        libFile.writeAsBytesSync(inpF.readAsBytesSync());
        isSupported = true;
      }
      if (targetArchitecture == .arm64) {
        final inpF = File(
          '/home/thancoder/source_to_static_lib/ffmpeg-8.1.1/dist_binaries/android/arm64-v8a/$libName',
        );
        libFile.writeAsBytesSync(inpF.readAsBytesSync());
        isSupported = true;
      }
    }
  } else {
    // online download
    final downloadUrl = getTargetDownloadUrl(targetOS, targetArchitecture);
    final libZipName = downloadUrl.split('/').last;
    final libCacheFile = File(join(rootDir, libZipName));
    // local cache မှာ ရှိလားစစ်မယ်
    if (libCacheFile.existsSync()) {
      // zip ဖြေရမယ်
      final archive = ZipDecoder().decodeBytes(libCacheFile.readAsBytesSync());
      for (var entry in archive) {
        if (!entry.isFile) continue;
        final bytes = entry.readBytes();
        libFile.writeAsBytesSync(bytes!);
      }
      return libFile;
    }
    // မရှိရင် download လုပ်ရမယ်
    final client = HttpClient();
    // ၄။ Request ပို့ပြီး ဒေါင်းလုဒ်လုပ်ခြင်း
    final request = await client.getUrl(Uri.parse(downloadUrl));
    final response = await request.close();

    if (response.statusCode == 200) {
      // Stream အတိုင်း ဖိုင်ထဲသို့ တိုက်ရိုက် ရေးချခြင်း (Memory မစားစေရန်)
      final fileSink = libCacheFile.openWrite();
      await response.pipe(fileSink);
      await fileSink.close();
      print('Download completed successfully: ${libCacheFile.path}');
    } else {
      throw HttpException(
        'Failed to download library. Status code: ${response.statusCode}',
      );
    }
  }

  if (!isSupported) {
    throw UnsupportedError(
      'Unsupported target OS ($targetOS) or Architecture ($targetArchitecture)',
    );
  }

  return libFile;
}

String getTargetDownloadUrl(OS targetOS, Architecture targetArchitecture) {
  if (targetOS == .linux) {
    return 'https://github.com/ThanCoder/ffmpeg_native_lib/releases/download/0.0.1/libffmpeg-linux_x64.zip';
  }
  if (targetOS == .android) {
    if (targetArchitecture == .arm) {
      return 'https://github.com/ThanCoder/ffmpeg_native_lib/releases/download/0.0.1/libffmpeg-arm64-v8a.zip';
    }
    if (targetArchitecture == .arm64) {
      return 'https://github.com/ThanCoder/ffmpeg_native_lib/releases/download/0.0.1/libffmpeg-arm64-v8a.zip';
    }
  }
  throw UnsupportedError(
    'Unsupported target OS ($targetOS) or Architecture ($targetArchitecture)',
  );
}
