import 'package:flutter/material.dart';
import 'package:sound_squid/screens/intro_screen.dart';
import 'package:sound_squid/screens/home_screen.dart';
import 'package:sound_squid/screens/search_screen.dart';
import 'package:sound_squid/services/spotify_auth_service.dart';
import 'package:sound_squid/services/spotify_api_service.dart';
import 'package:sound_squid/models/user.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final SpotifyAuthService spotifyAuthService = SpotifyAuthService();
  final SpotifyApiService spotifyApiService = SpotifyApiService();

  Future<User> getUser() async {
    return await spotifyApiService.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return(
      Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        body: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FutureBuilder(
                future: getUser(), 
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else {
                    // return Card.filled(
                    //   elevation: 8.0,
                    //   margin: const EdgeInsets.all(16.0),
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(16.0)
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(32.0),
                    //     child: Column(
                    //       children: [
                    //         CircleAvatar(
                    //           radius: 50.0,
                    //           backgroundImage: NetworkImage(snapshot.data.image),
                    //         ), 
                    //         Text(
                    //           snapshot.data.name,
                    //           style: Theme.of(context).textTheme.headlineSmall,
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // );
                    return Padding(
                      padding: const EdgeInsets.all(32.0), 
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50.0, 
                            backgroundImage: NetworkImage(snapshot.data.image)
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            snapshot.data.name, 
                            style: Theme.of(context).textTheme.headlineSmall
                          )
                        ],
                      )
                    );
                  }
                }
              ),
              ElevatedButton(
                onPressed: () => spotifyAuthService.logout(() {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IntroScreen()
                    )
                  );
                }),
                child: const Text("Log out")
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
        child: 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                icon: const Icon(Icons.home),
                iconSize: 30,
              ),
              IconButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchScreen())),
                icon: const Icon(Icons.search),
                iconSize: 30,
              ),
              IconButton(
                onPressed: () => {}, 
                icon: const Icon(Icons.person),
                iconSize: 30,
              )
            ],
          ),
        ),
      )
    );
  }
}