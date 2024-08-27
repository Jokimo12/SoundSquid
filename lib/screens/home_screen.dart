import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sound_squid/models/song.dart';
import 'package:sound_squid/screens/profile_screen.dart';
import 'package:sound_squid/screens/search_screen.dart';
import 'package:sound_squid/services/spotify_api_service.dart';

final String spotifyClientId = dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
final String spotifyRedirectUri = dotenv.env['SPOTIFY_REDIRECT_URI'] ?? ''; // Must be registered in Spotify Dashboard

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.songID, this.genre, this.artistID});

  final String? songID;
  final String? genre;
  final String? artistID;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final SpotifyApiService spotifyApiService = SpotifyApiService();
  final AudioPlayer audioPlayer = AudioPlayer();

  List<Song> songs = [];
  int currentSongIndex = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchRecommendedSongs();
  }

  void fetchRecommendedSongs() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Song> recommendedSongs = [];

      if(widget.songID != null) {
        recommendedSongs = await spotifyApiService.getRecommendedSongs(songSeed: widget.songID);
      } else if(widget.genre != null) {
        recommendedSongs = await spotifyApiService.getRecommendedSongs(genreSeed: widget.genre);
      } else if(widget.artistID != null) {
        recommendedSongs = await spotifyApiService.getRecommendedSongs(artistSeed: widget.artistID);
      } else {
        recommendedSongs = await spotifyApiService.getRecommendedSongs();
      }

      setState(() {
        songs = recommendedSongs;
        isLoading = false;
        audioPlayer.play(UrlSource(songs[0].preview!));
      });
    } catch (err) {
      debugPrint("$err");
      setState(() {
        isLoading = false;
      });
    }
  }

  void showNextSong() {
    if (currentSongIndex < songs.length - 1) {
      setState(() {
        currentSongIndex++;
      });
      audioPlayer.play(UrlSource(songs[currentSongIndex].preview!));
    } else {
      setState(() {
        currentSongIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SoundSquid")
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : songs.isNotEmpty
                ? Dismissible(
                    key: Key(songs[currentSongIndex].id),
                    direction: DismissDirection.horizontal,
                    onDismissed: (DismissDirection direction) {
                      showNextSong();
                      // Optionally, handle the swipe direction
                      if (direction == DismissDirection.startToEnd) {
                        print("Swiped right");
                      } else {
                        print("Swiped left");
                      }
                    },
                    background: Container(color: Theme.of(context).colorScheme.surface),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              "Songs from",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Image.asset(
                            "lib/assets/Spotify_Logo.png", 
                            width: 100, 
                            height: 100,
                            alignment: Alignment.topCenter,
                          ),
                          Image.network(songs[currentSongIndex].image, width: 250, height: 250,),
                          const SizedBox(height: 20,),
                          Text(
                            songs[currentSongIndex].name,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10,),
                          Text(
                            songs[currentSongIndex].artist,
                            style: Theme.of(context).textTheme.titleSmall,
                          ), 
                          const SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () => {}, 
                                icon: const Icon(Icons.volume_mute),
                                iconSize: 35,
                              ),
                              // Slider(value: value, onChanged: onChanged),
                              IconButton(
                                onPressed: () => {}, 
                                icon: const Icon(Icons.more),
                                iconSize: 35,
                              )
                            ],
                          ),
                        ],
                      )
                    ),
                  )
                : const Text('No songs available'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.home),
                iconSize: 30,
              ),
              IconButton(
                onPressed: () { 
                  audioPlayer.dispose();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchScreen()));
                },
                icon: const Icon(Icons.search),
                iconSize: 30,
              ),
              IconButton(
                onPressed: () {
                  audioPlayer.dispose();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                }, 
                icon: const Icon(Icons.person),
                iconSize: 30,
              )
            ],
          ),
        ),
    );
  }
}