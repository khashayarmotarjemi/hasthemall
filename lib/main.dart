import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final Api api = Api();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}

class Api {
  final List<String> names = [];
  final dio = Dio();

  Api() {}

  Future run() async {
    var names = [];

    final songNames = await createNames();

    final allShowsRes = await dio.get(
        'https://api.relisten.net/api/v2/artists/grateful-dead/shows/top?limit=30');

    for (var item in allShowsRes.data) {
      final showId = item['uuid'];

      final showRes =
          await dio.get('https://api.relisten.net/api/v3/shows/$showId');
      final show = showRes.data;
      final venue = show['venue'];
      final venueName = venue['name'];
      final year = show['year']['year'];
      final location = venue['location'];
      final setList = show['sources'][0]['sets'][0]['tracks'];
      for (var song in setList) {
        final title = song['title'];
        print(songNames.getId(title));
      }
    }

    return Future(() {});
  }

  Future<SongNames> createNames() async {
    final allSongs = await dio
        .get('https://api.relisten.net/api/v2/artists/grateful-dead/songs');

    List<dynamic> songs = allSongs.data;
    SongNames songNames =
        SongNames(songs.map((e) => cleanString(e['name'].toString())).toList());
    return songNames;
  }

  static String cleanString(text) {
    return text
        .toLowerCase()
        // .replaceAll('->', '/')
        // .replaceAll(RegExp(r'[^A-Za-z0-9 /]'), '')
        .replaceAll(RegExp(r"\s+"), ' ')
        .replaceAll(RegExp(r" \s+"), '');

  }
}

class SongNames {
  final List<String> songs;

  SongNames(this.songs);

  int getId(String name) {
    final cleanString = Api.cleanString(name);
    // songs.firstWhere((element) => element == name);
    var index = songs.indexOf(cleanString);

    if (index == -1) {
      print(cleanString);
      // songs.map((e) => e.similarityTo(name));
    }

    return index;
  }
}