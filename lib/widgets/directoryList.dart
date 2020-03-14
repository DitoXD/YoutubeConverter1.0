import 'dart:io' as io;

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class FirstRoute extends StatelessWidget {
  int audioListLen = 0, videoListLen = 0;
  List<io.FileSystemEntity> audioList, videoList;
  String path, audio, video;

 Future getLists() async {
      path = await localPath;
      String audioDir = "$path/Audio";
      String videoDir = "$path/Video";

      if(!io.Directory(audioDir).existsSync()){
        io.Directory(audioDir).createSync();
      }

      if(!io.Directory(videoDir).existsSync()){
        io.Directory(videoDir).createSync();
      }

      audioList = io.Directory(audioDir).listSync();
      videoList = io.Directory(videoDir).listSync();

      audioListLen = audioList.length;
      videoListLen = videoList.length;

      print(audioList);
      print(videoList);
      print(audioListLen);
      print(videoListLen);
    }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Downloads"),
            centerTitle: true,
            brightness: Brightness.light,
            backgroundColor: Colors.red,
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white30,
              tabs: [
                Tab(text: "Audio", icon: Icon(Icons.library_music)),
                Tab(text: "Video", icon: Icon(Icons.video_library)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView.builder(
                itemCount: audioListLen,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.music_note),
                      title: Text((audioList[index].path).replaceAll("$path/Audio/", "")),
                      subtitle: Text(audioList[index].path),
                      onTap: () => OpenFile.open(audioList[index].path),
                    ),
                  );
                },
              ),
              ListView.builder(
                itemCount: videoListLen,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.videocam),
                      title: Text((videoList[index].path).replaceAll("$path/Video/", "")),
                      subtitle: Text(videoList[index].path),
                      onTap: () => OpenFile.open(videoList[index].path),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
    future: getLists(),);
  }


}

