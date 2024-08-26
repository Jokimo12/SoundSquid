
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

final String spotifyClientId = dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
final String spotifyRedirectUri = dotenv.env['SPOTIFY_REDIRECT_URI'] ?? ''; // Must be registered in Spotify Dashboard

const String _charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

class SpotifyAuthService {
  String createCodeVerifier() {
    final List<int> values = List<int>.generate(
      128, 
      (i) => Random.secure().nextInt(_charset.length)
    );
    return values.map((value) => _charset[value]).join('');
  }

  Future<String> authenticateSpotify() async {
    String codeVerifier = createCodeVerifier();
    var hash = sha256.convert(utf8.encode(codeVerifier));
    String codeChallenge = base64Url.encode(hash.bytes)
      .replaceAll("=", "")
      .replaceAll("+", "-")
      .replaceAll("/", "_");

    final authUrl = 'https://accounts.spotify.com/authorize'
        '?response_type=code'
        '&client_id=$spotifyClientId'
        '&redirect_uri=$spotifyRedirectUri'
        '&scope=user-read-private%20user-read-email%20playlist-modify-public%20playlist-modify-private'
        '&code_challenge_method=S256'
        '&code_challenge=$codeChallenge';

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'sound-squid',
      );

      debugPrint(result);

      // Extract the authorization code from the result URL
      final code =  Uri.parse(result).queryParameters['code'];

      if (code != null) {
        String token = await _getAccessToken(code, codeVerifier); // Only call _getAccessToken if code is not null
        return token;
      } else {
        debugPrint('Authorization code is null');
        return '';
     }

    } catch (e) {
      // Handle errors here
      debugPrint('Error during Spotify authentication: $e');
      return '';
    }
  }

  Future<bool> checkAuthenticatedUser() async {
    String? accessToken = await secureStorage.read(key: 'access_token');
    String? refreshToken = await secureStorage.read(key: 'refresh_token');

    if(accessToken == null || refreshToken == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> logout(VoidCallback onSuccess) async {
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');

    onSuccess.call();
  }

  Future<String> refreshAccessToken() async {
    String? refreshToken = await secureStorage.read(key: 'refresh_token');

    if(refreshToken == null) {
      throw Exception("No refresh token");
    }

    const tokenUrl = 'https://accounts.spotify.com/api/token';
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    final body = {
      'client_id': spotifyClientId,
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    };

    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final accessToken = jsonResponse['access_token'];
        final refreshToken = jsonResponse['refresh_token'];

        await secureStorage.write(key: 'access_token', value: accessToken);
        await secureStorage.write(key: 'refresh_token', value: refreshToken);

        return accessToken;

      } else {
        debugPrint('Failed to refresh access token: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      debugPrint('Error while refreshing access token: $e');
      return '';
    }
  }

  Future<String> _getAccessToken(String code, String codeVerifier) async {
    const tokenUrl = 'https://accounts.spotify.com/api/token';
    const headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    final body = {
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': spotifyRedirectUri,
      'client_id': spotifyClientId,
      'code_verifier': codeVerifier
    };

    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final accessToken = jsonResponse['access_token'];
        final refreshToken = jsonResponse['refresh_token'];
        // final tokenType = jsonResponse['token_type'];
        
        await secureStorage.write(key: 'access_token', value: accessToken);
        await secureStorage.write(key: 'refresh_token', value: refreshToken);

        return accessToken;
      } else {
        debugPrint('Failed to get access token: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      debugPrint('Error while getting access token: $e');
      return '';
    }
  }
}
