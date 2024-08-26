import 'package:flutter/material.dart';
import 'package:sound_squid/screens/intro_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sound_squid/screens/home_screen.dart';
import 'package:sound_squid/services/spotify_auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final SpotifyAuthService spotifyAuthService = SpotifyAuthService();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Spotify Integration',
      theme: ThemeData(
        useMaterial3: true, 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffbb86fc),
          brightness: Brightness.dark,
        ).copyWith(
          primaryContainer: const Color(0xffbb86fc),
          onPrimaryContainer: Colors.black,
          secondaryContainer: const Color(0xff03dac6),
          onSecondaryContainer: Colors.black,
          error: const Color(0xffcf6679),
          onError: Colors.black,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.redHatDisplay(
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.redHatDisplay(
            fontWeight: FontWeight.bold
          ),
          titleMedium: GoogleFonts.redHatDisplay(
            fontWeight: FontWeight.bold
          ),
          titleSmall: GoogleFonts.redHatDisplay(
            color: Colors.grey
          ),
          labelLarge: GoogleFonts.redHatDisplay(
            fontWeight: FontWeight.bold
          ),
        )
      ),
      home: FutureBuilder<bool>(
        future: spotifyAuthService.checkAuthenticatedUser(), 
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              )
            );
          } else {
            if(snapshot.data == true) {
              return const HomeScreen();
            } else {
              return IntroScreen();
            }
          }
        }),
    );
  }
}