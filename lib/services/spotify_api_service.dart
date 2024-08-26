import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sound_squid/models/song.dart';
import 'package:sound_squid/models/artist.dart';
import 'package:sound_squid/models/user.dart';
import 'package:sound_squid/services/spotify_auth_service.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();
final SpotifyAuthService spotifyAuthService = SpotifyAuthService();

class SpotifyApiService {
  Future<List<Song>> getRecommendedSongs({String? songSeed, String? genreSeed, String? artistSeed}) async {
    String? accessToken = await secureStorage.read(key: 'access_token');

    if(accessToken == null) {
      throw Exception("No token found");
    }

    try {
      String baseUrl = 'https://api.spotify.com/v1/recommendations?market=US';

      if(songSeed != null) {
        baseUrl += '&seed_tracks=$songSeed';
      } else if(genreSeed != null) {
        baseUrl += '&seed_genres=$genreSeed';
      } else if(artistSeed != null) {
        baseUrl += '&seed_artists=$artistSeed';
      } else {
        baseUrl += '&seed_genres=pop';
      }

      final res = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $accessToken'
        }
      );

      if(res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<Song> songs = [];
        for (var track in data['tracks']) {
          Song song = Song.fromJson(track);
          if(song.preview != null) {
            songs.add(song);
          }
        }
        return songs;
      } else if(res.statusCode == 401) {
        accessToken = await spotifyAuthService.refreshAccessToken();

        final retryRes = await http.get(
          Uri.parse('https://api.spotify.com/v1/recommendations?market=US&seed_genres=pop'),
          headers: {
            'Authorization': 'Bearer $accessToken'
          }
        );

        if(retryRes.statusCode == 200) {
          final retryData = jsonDecode(retryRes.body);
          List<Song> songs = [];
          for(var track in retryData['tracks']) {
            Song song = Song.fromJson(track);
            if(song.preview != null) {
              songs.add(song);
            }
          }
          return songs;
        }
      }
    } catch (err) {
      print("$err");
    }

    throw Exception("Failed to load songs");
  }

  Future<String> getPreview(String token, String id) async {
    try {
      String? accessToken = await secureStorage.read(key: 'access_token');

      if(accessToken == null) {
        throw Exception("No token found");
      }

      final res = await http.get(
        Uri.parse('https://api.spotify.com/v1/tracks/$id'),
        headers: {
          'Authorization': 'Bearer $accessToken'
        }
      );

      if(res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["preview_url"];
      } else {
        throw Exception("Failed to get preview url");
      }
    } catch(err) {
      print("$err");
    }
    throw Exception("Failed to get previews");
  }

  Future<User> getProfile() async {
    try {
      String? accessToken = await secureStorage.read(key: 'access_token');

      if(accessToken == null) {
        throw Exception("No token found");
      }

      final res = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: {
          'Authorization': 'Bearer $accessToken'
        }
      );

      if(res.statusCode == 200) {
        final data = jsonDecode(res.body);
        User user = User.fromJson(data);
        return user;
      } else if(res.statusCode == 401) {
        accessToken = await spotifyAuthService.refreshAccessToken();

        final retryRes = await http.get(
          Uri.parse('https://api.spotify.com/v1/me'),
          headers: {
            'Authorization': 'Bearer $accessToken'
          }
        );
        
        if(retryRes.statusCode == 200) {
          final retryData = jsonDecode(retryRes.body);
          User user = User.fromJson(retryData);
          return user;
        }
      }
    } catch(err) {
      throw Exception(err);
    }
    throw Exception("Couldn't get user");
  }

  Future<List<Song>> searchForSong(String query) async {
    try {
      String? accessToken = await secureStorage.read(key: 'access_token');

      if(accessToken == null) {
        throw Exception("No token found");
      } 

      final res = await http.get(
        Uri.parse('https://api.spotify.com/v1/search?q=$query&type=track'),
        headers: {
          'Authorization': 'Bearer $accessToken'
        }
      );

      if(res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<Song> items = [];
        final tracks = data['tracks'];
        for (var item in tracks['items']) {
          Song song = Song.fromJson(item);
          items.add(song);
        }
        return items;
      } else if(res.statusCode == 401) {
        accessToken = await spotifyAuthService.refreshAccessToken();

        final retryRes = await http.get(
          Uri.parse('https://api.spotify.com/v1/search?q=$query&type=track'),
          headers: {
            'Authorization': 'Bearer $accessToken'
          }
        );

        if(retryRes.statusCode == 200) {
          final retryData = jsonDecode(retryRes.body);
          List<Song> items = [];
          final tracks = retryData['tracks'];
          for(var item in tracks['items']) {
            Song song = Song.fromJson(item);
            items.add(song);
          }
          return items;
        }
      }
    } catch (err) {
      print('$err');
    }
    throw Exception("Failed to get items");
  }

  Future<List<Artist>> searchForArtist(String query) async {
    try {
      String? accessToken = await secureStorage.read(key: 'access_token');

      if(accessToken == null) {
        throw Exception("No token found");
      } 

      final res = await http.get(
        Uri.parse('https://api.spotify.com/v1/search?q=$query&type=artist'),
        headers: {
          'Authorization': 'Bearer $accessToken'
        }
      );

      if(res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<Artist> items = [];
        final artists = data['artists'];
        for (var item in artists['items']) {
          Artist artist = Artist.fromJson(item);
          items.add(artist);
        }
        return items;
      } else if(res.statusCode == 401) {
        accessToken = await spotifyAuthService.refreshAccessToken();

        final retryRes = await http.get(
          Uri.parse('https://api.spotify.com/v1/search?q=$query&type=artist'),
          headers: {
            'Authorization': 'Bearer $accessToken'
          }
        );

        if(retryRes.statusCode == 200) {
          final retryData = jsonDecode(retryRes.body);
          List<Artist> items = [];
          final artists = retryData['artists'];
          for (var item in artists['items']) {
            Artist artist = Artist.fromJson(item);
            items.add(artist);
          }
          return artists;
        }
      }
    } catch (err) {
      throw Exception(err);
    }
    throw Exception("Failed to get items");
  }

  Future<List<dynamic>> getGenres() async {
    try {
      String? accessToken = await secureStorage.read(key: 'access_token');

      if(accessToken == null) {
        throw Exception("No token found");
      }

      final res = await http.get(
        Uri.parse('https://api.spotify.com/v1/recommendations/available-genre-seeds'),
        headers: {
          "Authorization": "Bearer $accessToken"
        }, 
      );

      if(res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<dynamic> genres = data['genres'];
        return genres;
      } else if(res.statusCode == 401) {
        accessToken = await spotifyAuthService.refreshAccessToken();

        final retryRes = await http.get(
          Uri.parse('https://api.spotify.com/v1/recommendations/available-genre-seeds'),
          headers: {
            "Authorization": "Bearer $accessToken"
          }, 
        );

        if(retryRes.statusCode == 200) {
          final retryData = jsonDecode(retryRes.body);
          List<dynamic> genres = retryData['genres'];
          return genres;
        }
      }
    } catch(err) {
      throw Exception("$err");
    }
    throw Exception("Failed to get genres");
  }
}
