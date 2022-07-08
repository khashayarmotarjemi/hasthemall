import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';

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

    final songNameRepo = SongNameRepo(dio);
    bool loadedNames = await songNameRepo.loadNames();
    if (loadedNames) {
      final allShowsRes = await dio.get(
          'https://api.relisten.net/api/v2/artists/grateful-dead/shows/top?limit=5');

      for (var item in allShowsRes.data) {
        final showId = item['uuid'];

        final showRes =
            await dio.get('https://api.relisten.net/api/v3/shows/$showId');
        final show = showRes.data;
        final venue = show['venue'];
        final venueName = venue['name'];
        final year = show['year']['year'];
        final location = venue['location'];
        final List<dynamic> songList = show['sources'][0]['sets'][0]['tracks'];

        final SetList setList =
            SetList(songList.map((e) => e['title']).toList(), songNameRepo);
      }
    } else {
      print("error");
    }

    return Future(() {});
  }
}

class SongNameRepo {
  final Dio dio;

  final List<String> songs = [];

  SongNameRepo(this.dio);

  Future<bool> loadNames() async {
    final allSongs = await dio
        .get('https://api.relisten.net/api/v2/artists/grateful-dead/songs');
    List<dynamic> list = allSongs.data;

    for (var song in list) {
      songs.add(cleanWhiteSpace(song['name'].toString()));
    }

    // print(songs);

    return songs.isNotEmpty;
  }

  static String cleanWhiteSpace(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r"\s+"), ' ')
        .replaceAll(RegExp(r" \s+"), '');
  }

  static String removeSymbols(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^A-Za-z0-9 /]'), '');
  }
}

class SetList {
  final SongNameRepo _songNameRepo;
  final List<String> songs = [];

  SetList(List<dynamic> nameStrings, this._songNameRepo) {
    for (var element in nameStrings) {
      _addSong(element.toString());
    }
  }

  void _addSong(String rawName) {
    final name = SongNameRepo.cleanWhiteSpace(rawName);
    if (_songNameRepo.songs.contains(name)) {
      songs.add(name);
    } else {
      _handleSpecialCase(name);
    }
  }

  String getClosest(String name) {
    final bestMatch = name.bestMatch(_songNameRepo.songs).bestMatch;
    if ((bestMatch.rating ?? 0.0).toDouble() > 0.5) {
      return bestMatch.target ?? name;
    } else {
      return name;
    }
  }

  void _handleSpecialCase(String name) {
    if (name.contains(RegExp(r"-|>|\/|,"))) {
      final parts = name.split(RegExp(r"[->|>|\/|,]"));

      for (var rawElement in parts) {
        final element = SongNameRepo.cleanWhiteSpace(
            SongNameRepo.removeSymbols(rawElement));

        if (_songNameRepo.songs.contains(element)) {
          songs.add(element);
        } else {
          print("PART: rawelement:$rawElement $element:best:${getClosest(element)}");
        }
      }
    } else {
      print("SPEC: $name : best: ${getClosest(name)}");
    }
  }
}

class SetListSong {}
