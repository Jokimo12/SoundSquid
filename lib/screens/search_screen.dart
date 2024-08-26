import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sound_squid/screens/home_screen.dart';
import 'package:sound_squid/screens/profile_screen.dart';
import 'package:sound_squid/services/spotify_api_service.dart';

class SearchScreen extends StatefulWidget {

  @override 
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final SpotifyApiService spotifyApiService = SpotifyApiService();
  final List<bool> selectedButtons = [false, true, false];
  final List<Text> buttons = const [Text("Songs"), Text("Genres"), Text("Artists")];
  List<dynamic> genres = [];
  String searchString = '';
  bool isLoading = false;
  final List<Color> colors = [Colors.red, Colors.orange, Colors.green, Colors.blue, Colors.purple];

  @override
  void initState() {
    super.initState();
    _getGenres();
  }

  void _getGenres() async {
    setState(() {
      isLoading = true;
    });

    genres = await spotifyApiService.getGenres();

    setState(() {
      isLoading = false;
    });
  }

  Future<List<dynamic>> _fetchSongs(String query) async {
    if(query.isEmpty) {
      return [];
    }
    return await spotifyApiService.searchForSong(query);
  }

  Future<List<dynamic>> _fetchArtists(String query) async {
    if(query.isEmpty) {
      return [];
    }
    var result = await spotifyApiService.searchForArtist(query);
    debugPrint('$result');
    return result;
  }

  String _capitalize(String str) => str.isNotEmpty ? str = '${str[0].toUpperCase()}''${str.substring(1)}' : str;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SoundSquid"),
      ),
      body: Center(
        child: Column(
          children: [
            // const SizedBox(height: 40,),
            Padding(
              padding: const EdgeInsets.all(10.0), 
              child: TextField(
                onChanged: (query) {
                  setState(() {
                    searchString = query;
                  });
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search), 
                  labelText: 'Search for a song or genre', 
                  border: OutlineInputBorder(),
                )
              ),
            ),
            LayoutBuilder(builder: (context, constraints) {
              return ToggleButtons(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                // borderWidth: 2.0,
                constraints: BoxConstraints.expand(
                  width: (constraints.maxWidth / 3) - 10,
                  height: 45
                ),
                fillColor: Theme.of(context).colorScheme.primaryContainer,
                selectedColor: Theme.of(context).colorScheme.inverseSurface,
                selectedBorderColor: Theme.of(context).colorScheme.primaryContainer,
                color: Theme.of(context).colorScheme.onSurface,
                borderColor: Theme.of(context).colorScheme.onSurface,
                onPressed: (int index) async {
                  setState(() {
                    for(int i = 0; i < selectedButtons.length; i++) {
                      selectedButtons[i] = i == index;
                    }
                  });
                },
                isSelected: selectedButtons,
                children: buttons
              );
            }),
            const SizedBox(height: 10,),
            Expanded(
              child: selectedButtons[0] ? _buildSongsTab() : (selectedButtons[1] ? _buildGenresTab() : _buildArtistsTab()),
            ),
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
                onPressed: () => {},
                icon: const Icon(Icons.search),
                iconSize: 30,
              ),
              IconButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen())), 
                icon: const Icon(Icons.person),
                iconSize: 30,
              )
            ],
          ),
        ),
    );
  }
  Widget _buildSongsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchSongs(searchString),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No songs found"));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.network(snapshot.data![index].image, width: 70, height: 70),
                title: Text(
                  snapshot.data![index].name,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                subtitle: Text(snapshot.data![index].artist),
                onTap: () {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => HomeScreen(songID: snapshot.data![index].id))
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  Widget _buildGenresTab() {
    List<dynamic> filteredGenres = genres;

    if (searchString.isNotEmpty) {
      filteredGenres = genres.where((genre) => genre.toLowerCase().contains(searchString.toLowerCase())).toList();
    }

    if (filteredGenres.isEmpty) {
      return const Center(child: Text("No genres found"));
    }

    return ListView.builder(
      itemCount: filteredGenres.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: Material(
            child: ListTile(
              title: Text(
                _capitalize(filteredGenres[index]),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              tileColor: colors[Random().nextInt(colors.length)],
              onTap: () {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => HomeScreen(genre: filteredGenres[index].toLowerCase()))
                );
              },
            ),
          ),
        );
      },
    );
  }
Widget _buildArtistsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchArtists(searchString),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No artists found"));
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.network(snapshot.data![index].image, width: 70, height: 70),
                title: Text(
                  snapshot.data![index].name,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                subtitle: Text(
                  snapshot.data![index].genres.isNotEmpty
                    ? 'Genres: ${snapshot.data![index].genres.take(3).map((genre) => _capitalize(genre)).join(', ')}'
                    : 'Popularity: ${snapshot.data![index].popularity}',
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => HomeScreen(artistID: snapshot.data![index].id))
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

