import 'package:flutter/material.dart';
import 'package:ffmpeg_native_lib/ffmpeg_native_lib.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final result = StringBuffer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FFMpeg Native Lib')),
      body: SingleChildScrollView(child: Text(result.toString())),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          result.clear();
          result.writeln('**************Version****************');
          result.writeln('avVersionInfo: $avVersionInfo');
          result.writeln('avutilVersion: $avutilVersion');
          result.writeln('avcodecVersion: $avcodecVersion');
          result.writeln('swscaleVersion: $swscaleVersion');
          result.writeln('avdeviceVersion: $avdeviceVersion');
          result.writeln('avfilterVersion: $avfilterVersion');
          result.writeln('avformatVersion: $avformatVersion');
          result.writeln('**************Configure****************');
          //**************Configure**** */
          result.writeln('**************avutilConfiguration****************');
          result.writeln('avutilConfiguration: $avutilConfiguration');
          result.writeln(
            '**************swresampleConfiguration****************',
          );
          result.writeln('swresampleConfiguration: $swresampleConfiguration');
          result.writeln('**************avcodecConfiguration****************');
          result.writeln('avcodecConfiguration: $avcodecConfiguration');
          result.writeln('**************swscaleConfiguration****************');
          result.writeln('swscaleConfiguration: $swscaleConfiguration');
          result.writeln('**************avdeviceConfiguration****************');
          result.writeln('avdeviceConfiguration: $avdeviceConfiguration');
          result.writeln('**************avfilterConfiguration****************');
          result.writeln('avfilterConfiguration: $avfilterConfiguration');
          result.writeln('**************avformatConfiguration****************');
          result.writeln('avformatConfiguration: $avformatConfiguration');
          // debugPrint(result.toString());
          setState(() {});
        },
      ),
    );
  }
}
