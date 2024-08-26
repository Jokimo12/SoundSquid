import 'package:flutter/material.dart';
import 'package:sound_squid/services/spotify_api_service.dart';
import 'home_screen.dart';
import '../services/spotify_auth_service.dart';

class IntroScreen extends StatelessWidget {
  final SpotifyAuthService spotifyAuthService = SpotifyAuthService();
  final SpotifyApiService spotifyApiService = SpotifyApiService();

  Future<void> authenticateAndNavigate(BuildContext context) async {
    String token = await spotifyAuthService.authenticateSpotify();
    if (token != '') {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: RouteSettings(arguments: token)
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body:
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('lib/assets/logo.png'),
              Text(
                style: Theme.of(context).textTheme.titleLarge,
                "SoundSquid"
              ),
              ElevatedButton(
                onPressed: () async => await authenticateAndNavigate(context), 
                child: const Text("Log in")
              )
            ]
          )
        ),
    );
  }
}