import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_extractor/youtube_extractor.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import 'package:youtube_converter/widgets/directoryList.dart';

void main() {
  runApp(
      MaterialApp(
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      )
  );

  var navigationColor = Colors.white;

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: navigationColor,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

Future<String> get localPath async {
  final directory = await getExternalStorageDirectory();
  return directory.path;
}

class _HomePageState extends State<HomePage> {
  var color1 = Colors.red;
  var color2 = Colors.white;
  bool isProcessed = false, downloading = false;
  String audioUrl, videoUrl, title, progress;

//  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//  void initState(){
//    super.initState();
//    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//    var android = new AndroidInitializationSettings("@mipmap/yca");
//    var iOS = new IOSInitializationSettings();
//    var initSettings = new InitializationSettings(android, iOS);
//    flutterLocalNotificatioinsPlugin.initialize(initSettings, selectNotification: onSelectNotification);
//
//  }


  var extractor = YouTubeExtractor();

  TextEditingController TextCtrler1 = TextEditingController();
  TextEditingController TextCtrler2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: FlatButton.icon(
                    onPressed:() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FirstRoute()),
                      );
                    },
                    icon: Icon(Icons.subdirectory_arrow_right),
                    label: Text("Downloads"),
                  ),
                ),
              ),
              Image(
                image: AssetImage("assets/youtubeLogo.png"),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Youtube URL",
                  ),
                  controller: TextCtrler1,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "File Name",
                  ),
                  controller: TextCtrler2,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  color: color1,
                  textColor: color2,
                  label: Text("Process"),
                  elevation: 10,
                  onPressed: () {
                    getDownloadUrl();
                  }
              ),
              SizedBox(
                height: 40,
              ),
              isProcessed==true?
              Container(
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton.icon(
                          label: Text("Video"),
                          icon: Icon(Icons.videocam),
                          color: color1,
                          textColor: color2,
                          onPressed: () {
                            downloadVideo();
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        RaisedButton.icon(
                          label: Text("Audio"),
                          icon: Icon(Icons.audiotrack),
                          color: color1,
                          textColor: color2,
                          onPressed: () {
                            downloadAudio();
                          },
                        )
                      ],
                    )
              ):Container(),
              downloading==true?
                  Container(
                    height: 80,
                    width: 300,
                    child: Card(
                      color: color1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Downloading $progress", style: TextStyle(color: color2, fontSize: 24)),
                          SizedBox(
                            width: 15,
                          ),
                          CircularProgressIndicator(backgroundColor: color2,)
                        ],
                      ),
                    ),
                  )
              :Container(),
              Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom))
            ],
          )
        ),
      ),
    );
  }

  void getDownloadUrl() async {

    setState(() {
      isProcessed = false;
    });

    String url = TextCtrler1.text;

    if(url.isNotEmpty) {
      url = url.replaceAll("https://www.youtube.com/watch?v=", "");
      url = url.replaceAll("https://youtu.be/", "");

      var audioInfo = await extractor.getMediaStreamsAsync(url);
      audioUrl = audioInfo.audio.first.url;
      print(audioUrl);

      var videoInfo = await extractor.getMediaStreamsAsync(url);
      videoUrl = videoInfo.muxed.first.url;
      print(videoUrl);

      setState(() {
        isProcessed = true;
      });
    }
  }

  Future downloadAudio() async {
    String name = TextCtrler2.text;
    setState(() {
      downloading = true;
      isProcessed = false;
    });

    if(name.isNotEmpty) {
      final String path = await localPath;

      Dio dio = Dio();

      await dio.download(audioUrl, "$path/Audio/$name.mp3",
          onReceiveProgress: (rec, total) {
            setState(() {
              downloading = true;
              progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
            });
          });



//      File fileSave = File("$path/Audio/$name.mp3");
//      var request = await http.get(audioUrl);
//      var bytes = request.bodyBytes;
//      await fileSave.writeAsBytes(bytes);
//      print(fileSave.path);
    }
    setState(() {
      downloading = false;
    });
  }

  Future downloadVideo() async {
    String name = TextCtrler2.text;
    setState(() {
      downloading = true;
      isProcessed = false;
    });

    if(name.isNotEmpty) {
      final String path = await localPath;

      Dio dio = Dio();

      await dio.download(videoUrl, "$path/Video/$name.mp4",
          onReceiveProgress: (rec, total) {
            setState(() {
              downloading = true;
              progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
            });
          });





//      File fileSave = File("$path/Video/$name.mp4");
//      var request = await http.get(videoUrl);
//      var bytes = request.bodyBytes;
//      await fileSave.writeAsBytes(bytes);
//      print(fileSave.path);
    }
    setState(() {
      downloading = false;
    });
  }

}