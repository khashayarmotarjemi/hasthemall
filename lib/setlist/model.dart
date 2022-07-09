import 'package:hasthemall/api.dart';
import 'package:hasthemall/main.dart';
import 'package:string_similarity/string_similarity.dart';

class SetList {
  final SongNameRepo _songNameRepo;
  final int year;
  final String location;
  final String venue;
  final List<SetListItem> songs = [];

  SetList(List<dynamic> nameStrings, this._songNameRepo, this.year,
      this.location, this.venue) {
    for (var element in nameStrings) {
      _addSong(element.toString());
    }
  }

  static String cleanWhiteSpace(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r"\s+"), ' ')
        .replaceAll(RegExp(r"[ ,;:/>.-]*$"), '');
  }

  static String removeSymbols(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^A-Za-z0-9 /]'), '');
  }

  void _addSong(String rawName) {
    final name = cleanWhiteSpace(rawName);
    if (_songNameRepo.songs.contains(name)) {
      songs.add(Song(name));
    } else {
      _handleSpecialCase(name);
    }
  }

  Rating getClosest(String name) {
    return name.bestMatch(_songNameRepo.songNames).bestMatch;
  }

  void _handleSpecialCase(String name) {
    if (name.contains(RegExp(r"-|>|\/|,"))) {
      final parts = name.split(RegExp(r"[>|\/|,]"));

      for (var rawElement in parts) {
        final element = cleanWhiteSpace(rawElement);

        if (_songNameRepo.songs.contains(element)) {
          songs.add(Song(element));
        } else {
          Rating bestMatch = getClosest(element);

          if ((bestMatch.rating ?? 0.0) > 0.5) {
            // _addSong(bestMatch.target ?? "");
            songs.add(Song(bestMatch.target ?? ""));
          } else {
            songs.add(UnidSong(element));
            // print(
            //     "PART: rawelement:$rawElement $element : best : ${getClosest(
            //         element).target} : rate: ${getClosest(element).rating}");
          }
        }
      }
    } else {
      Rating bestMatch = getClosest(name);

      if ((bestMatch.rating ?? 0.0) > 0.5) {
        // _addSong(bestMatch.target ?? "");
        songs.add(Song(bestMatch.target ?? ""));
      } else {
        songs.add(UnidSong(name));
      }
    }
  }
}

abstract class SetListItem {
  final String name;

  SetListItem(this.name);
}

class Song extends SetListItem {
  Song(super.name);
}

class UnidSong extends SetListItem {
  UnidSong(super.name);
}
