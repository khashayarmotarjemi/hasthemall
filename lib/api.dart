import 'dart:async';

import 'package:dio/dio.dart';
import 'package:hasthemall/setlist/model.dart';

class Api {
  final StreamController<ApiOutput> output = StreamController();
  final dio = Dio();
  final int limit = 10;
  int progress = 0;

  Future<bool> run() async {
    final songNameRepo = SongNameRepo(dio);
    bool loadedNames = await songNameRepo.loadNames();
    if (loadedNames) {
      final allShowsRes = await dio.get(
          'https://api.relisten.net/api/v2/artists/grateful-dead/shows/top?limit=$limit');

      List<SetList> setLists = [];

      for (var item in allShowsRes.data) {
        progress++;
        output.add(ApiOutput([], progress / limit));
        final showId = item['uuid'];

        final showRes =
            await dio.get('https://api.relisten.net/api/v3/shows/$showId');
        final show = showRes.data;
        final venue = show['venue'];
        final venueName = venue['name'].toString();
        final year = int.parse(show['year']['year']);
        final location = venue['location'].toString();
        final List<dynamic> songList = show['sources'][0]['sets'][0]['tracks'];

        final SetList setList = SetList(
            songList.map((e) => e['title']).toList(),
            songNameRepo,
            year,
            location,
            venueName);

        setLists.add(setList);
      }

      output.add(ApiOutput(setLists, 1.0));

      return true;
    } else {
      return false;
    }
  }
}

class SongNameRepo {
  final Dio dio;

  final List<Song> songs = [];
  final List<String> songNames = [];

  SongNameRepo(this.dio);

  Future<bool> loadNames() async {
    final allSongs = await dio
        .get('https://api.relisten.net/api/v2/artists/grateful-dead/songs');
    List<dynamic> list = allSongs.data;

    for (var song in list) {
      final name = SetList.cleanWhiteSpace(song['name'].toString());
      songs.add(Song(name));
      songNames.add(name);
    }

    return songs.isNotEmpty;
  }
}

class ApiOutput {
  final List<SetList> setLists;
  final double progress;

  ApiOutput(this.setLists, this.progress);
}
